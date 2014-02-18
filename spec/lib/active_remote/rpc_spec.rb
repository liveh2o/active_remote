require 'spec_helper'

describe ActiveRemote::RPC do
  subject { Tag.new }

  describe ".remote_call" do
    let(:args) { double(:args) }
    let(:response) { double(:response) }

    before { Tag.any_instance.stub(:execute) }

    it "calls the given RPC method" do
      Tag.any_instance.should_receive(:execute).with(:remote_method, args)
      Tag.remote_call(:remote_method, args)
    end

    it "returns the response" do
      Tag.any_instance.stub(:last_response).and_return(response)
      Tag.remote_call(:remote_method, args).should eq response
    end
  end

  describe ".request" do
    let(:attributes) { Hash.new }

    it "builds an RPC request" do
      Tag.request(:create, attributes).should eq Generic::Remote::Tag.new(attributes)
    end
  end

  describe ".request_type" do
    it "fetches the request type for the given RPC method" do
      Tag.request_type(:search).should eq Generic::Remote::TagRequest
    end
  end

  describe "#execute" do
    let(:request) { double(:request) }

    it "calls the given RPC method" do
      mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))
      subject.execute(:create, request)
    end

    it "sets the last request" do
      mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))

      subject.execute(:create, request)
      subject.last_request.should eq(request)
    end

    context "when request args is a hash" do
      let(:args){ Hash.new }
      let(:request) { double(:request) }

      before {
        subject.stub(:request).and_return(request)
        mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))
      }

      it "creates a request" do
        subject.should_receive(:request).with(:create, args)
        subject.execute(:create, args)
      end
    end

    context "when a request succeeds" do
      let(:success_response) { double(:status => 'success', :awesome_town => true, :to_hash => {}) }

      before {
        mock_remote_service(Tag.service_class, :create, :response => success_response)
      }

      it "sets the last response" do
        subject.execute(:create, request)
        subject.last_response.should eq(success_response)
      end
    end

    context "when a request fails" do
      let(:error_response) { double(:error, :message => "Boom goes the dynamite!") }

      before {
        mock_remote_service(Tag.service_class, :create, :error => error_response)
      }

      it "raises an exception" do
        expect { subject.execute(:create, request) }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end
end
