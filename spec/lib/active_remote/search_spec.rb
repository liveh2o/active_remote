require 'spec_helper'

describe ActiveRemote::Search do
  describe ".find" do
    let(:args) { Hash.new }
    let(:record) { double(:record) }
    let(:records) { [ record ] }

    before { Tag.stub(:search).and_return(records) }

    it "searches with the given args" do
      Tag.should_receive(:search).with(args)
      Tag.find(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        Tag.find(args).should eq record
      end
    end

    context "when no records are returned" do
      before { Tag.stub(:search).and_return([]) }

      it "raise an exception" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound)
      end

      it "gives the class of the remote record not found in the message" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound, /Tag/)
      end
    end
  end

  describe ".search" do
    context "given args that respond to :to_hash" do
      let(:args) { Hash.new }

      before {
        Tag.any_instance.stub(:_active_remote_search)
      }

      it "searches with the given args" do
        Tag.any_instance.should_receive(:_active_remote_search).with(args)
        Tag.search(args)
      end

      it "returns records" do
        records = double(:records)

        Tag.any_instance.stub(:serialize_records).and_return(records)
        Tag.search(args).should eq records
      end
    end

    context "given args that don't respond to :to_hash" do
      let(:request) { double(:request) }

      it "raises an exception" do
        expect { described_class.search(request) }.to raise_exception
      end
    end
  end

  describe "#_active_remote_search" do
    let(:args) { Hash.new }

    subject { Tag.new }

    it "runs callbacks" do
      subject.should_receive(:run_callbacks).with(:search)
      subject._active_remote_search(args)
    end

    it "executes the search" do
      subject.should_receive(:execute).with(:search, args)
      subject._active_remote_search(args)
    end
  end

  describe "#reload" do
    let(:args) { { :guid => 'foo' } }
    let(:attributes) { HashWithIndifferentAccess.new(:guid => 'foo', :name => 'bar', :updated_at => nil) }

    subject { Tag.new(args) }

    before {
      subject.stub(:_active_remote_search)
      subject.stub(:last_response).and_return(attributes)
    }

    it "reloads the record" do
      subject.should_receive(:_active_remote_search).with(args)
      subject.reload
    end

    it "assigns new attributes" do
      subject.reload
      subject.attributes.should eq attributes
    end
  end
end
