require 'spec_helper'
require 'atlas/abacus/tag_service'

class FooBarService; end

module Foo
  class BarService; end
end

module ActiveRemote::Foo
  class Bar < ActiveRemote::Base
    # Let's mimic Tag's attributes so it's easier to test...
    attr_accessor :id, :guid, :name
  end
end

describe ActiveRemote::Base do
  let(:message) do
    double(:protos, :fields => [ double(:field, :name => :records, :repeated? => true) ], :records => [])
  end

  its(:has_errors?) { should be_false }

  describe ".new" do
    context "when initialized with a protobuf object" do
      it "sets attributes" do
        described_class.new()
      end
    end
  end

  describe ".find" do
    let(:args) { {} }

    before do
      described_class.any_instance.should_receive(:execute).with(:search, args)
      described_class.any_instance.stub(:last_response).and_return(message)
    end

    it "searches with the given arguments" do
      described_class.find(args)
    end

    it "is aliased as search" do
      described_class.search(args)
    end
  end

  describe ".find!" do
    let(:request) { double(:request) }

    before do
      described_class.any_instance.should_receive(:execute!).with(:search, request)
      described_class.any_instance.stub(:last_response).and_return(message)
    end

    it "searches with the given arguments and skips sanitization" do
      described_class.find!(request)
    end

    it "is aliased as search!" do
      described_class.search!(request)
    end
  end

  describe ".save" do
    before { described_class.any_instance.should_receive(:save) }

    it "saves a remote record with the given attributes" do
      described_class.save({})
    end

    it "is aliased as create" do
      described_class.create({})
    end

    it "is aliased as update" do
      described_class.update({})
    end
  end

  describe ".create_all" do
    it "creates remote records" do
      records = []
      described_class.any_instance.should_receive(:execute).with(:create_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.create_all(records)
    end
  end

  describe ".create_all!" do
    it "creates remote records without building a message" do
      request = double(:request)
      described_class.any_instance.should_receive(:execute!).with(:create_all, request)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.create_all!(request)
    end
  end

  describe ".update_all" do
    it "updates remote records" do
      records = []
      described_class.any_instance.should_receive(:execute).with(:update_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.update_all(records)
    end
  end

  describe ".update_all!" do
    it "updates remote records without building a message" do
      request = double(:request)
      described_class.any_instance.should_receive(:execute!).with(:update_all, request)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.update_all!(request)
    end
  end

  describe ".delete_all" do
    it "deletes remote records" do
      records = []
      described_class.any_instance.should_receive(:execute).with(:delete_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.delete_all(records)
    end
  end

  describe ".delete_all!" do
    it "deletes remote records without building a message" do
      request = double(:request)
      described_class.any_instance.should_receive(:execute!).with(:delete_all, request)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.delete_all!(request)
    end
  end

  describe ".service_class" do
    before { ActiveRemote::Foo::Bar.service_class = nil }

    context "when not set" do
      it "is inferred" do
        ActiveRemote::Foo::Bar.service_class.should eq(Foo::BarService)
      end
    end

    it "is settable" do
      ActiveRemote::Foo::Bar.service_class = FooBarService
      ActiveRemote::Foo::Bar.service_class.should eq(FooBarService)
    end
  end

  describe "#delete" do
    it "deletes a remote record" do
      subject.should_receive(:execute).with(:delete, subject.attributes)
      subject.delete
    end
  end

  describe "#execute" do
    let(:args){ Hash.new }
    let(:request) { double(:request) }

    before {
      subject.stub(:request).and_return(request)
      subject.stub(:execute!)
    }

    it "creates a request" do
      subject.should_receive(:request).with(:create, args, {})
      subject.execute(:create, args)
    end

    it "creates a request with options" do
      records = []
      options = { :bulk => true }
      subject.should_receive(:request).with(:create, records, options)
      subject.execute(:create, records, options)
    end

    it "executes the given RPC method" do
      subject.should_receive(:execute!).with(:create, request)
      subject.execute(:create, args)
    end
  end

  describe "#execute!" do
    let(:request) { double(:request) }

    before {
      described_class.service_class = FooBarService
    }
    after { described_class.service_class = nil }

    context "when called" do
      before {
        mock_remote_service(described_class.service_class, :create, :response => double(:to_hash => {}))
      }

      it "calls the given RPC method" do
        # The expectation is handled by mock_remote_service
        subject.execute!(:create, request)
      end

      it "sets the last request" do
        subject.execute!(:create, request)
        subject.last_request.should eq(request)
      end
    end

    context "when a request succeeds" do
      let(:success_response) { double(:status => 'success', :awesome_town => true, :to_hash => {}) }

      before {
        mock_remote_service(described_class.service_class, :create, :response => success_response)
      }

      it "doesn't have errors" do
        subject.execute!(:create, request)
        subject.has_errors?.should be_false
      end

      it "sets the last response" do
        subject.execute!(:create, request)
        subject.last_response.should eq(success_response)
      end

      it "mimics the response" do
        subject.execute!(:create, request)
        subject.should respond_to(:awesome_town)
      end
    end

    context "when a request fails" do
      let(:error_response) { double(:error, :message => "Boom goes the dynamite!") }

      before {
        mock_remote_service(described_class.service_class, :create, :error => error_response)
      }

      it "has errors" do
        subject.execute!(:create, request)
        subject.has_errors?.should be_true
      end

      it "sets the last response" do
        subject.execute!(:create, request)
        subject.last_response.should eq(error_response)
      end
    end
  end

  # TODO: Create proto messages & endpoints specifically for these tests.
  # They will be more robust if they don't rely on proto messages in Atlas.
  context "when building messages" do
    let(:records) { [ { :name => 'Foo' }, { :name => 'Bar' } ] }
    let(:attributes) { records.first }

    after { described_class.service_class = nil }

    it "creates a message" do
      pending
      described_class.service_class = Abacus::TagService
      expected_message = Abacus::Tag.new(attributes)

      package = subject.request(:create, attributes)
      package.should be_similar_to(expected_message)
    end

    it "creates a bulk message" do
      pending
      described_class.service_class = Abacus::TagService
      expected_message = Abacus::Tags.new

      package = described_class.request(:create_all, records, :bulk => true)
      package.should be_similar_to(expected_message)
    end

    it "creates a message with nested messages" do
      pending
      described_class.service_class = Abacus::TransactionService
      records_hash = { :status => { :status => 7 }, :guid => 'GUID' }

      expected_message = Abacus::Transaction.new
      expected_message.guid = records_hash[:guid]
      expected_message.status = Status.new(records_hash.fetch(:status)) # status => HIDDEN

      message = subject.request(:update, records_hash)
      message.should be_similar_to(expected_message)
    end
  end

  describe "#save" do
    let(:subclass) { ActiveRemote::Foo::Bar }

    context "without an id or guid" do
      it "calls create" do
        remote = subclass.new(:name => 'foo')
        remote.should_receive(:execute).with(:create, remote.attributes)
        remote.save
      end
    end

    context "with an id" do
      it "calls update" do
        remote = subclass.new(:id => 1)
        remote.should_receive(:execute).with(:update, remote.attributes)
        remote.save
      end
    end

    context "with a guid" do
      it "calls update" do
        remote = subclass.new(:guid => 'GUID')
        remote.should_receive(:execute).with(:update, remote.attributes)
        remote.save
      end
    end
  end

  describe '#remote' do
    let(:subclass) { ActiveRemote::Foo::Bar }

    it 'sets the service class on the remote' do
      described_class.remote subclass
      subject.service_class.should eq(subclass)
    end
  end
end
