require 'spec_helper'

describe ActiveRemote::Search do
  let(:records) { [ Generic::Remote::Tag.new ] }
  let(:response) { Generic::Remote::Tags.new(:records => records) }
  let(:rpc) { double(:rpc) }

  describe ".find" do
    let(:args) { Hash.new }
    let(:record) { double(:record) }
    let(:records) { [ record ] }

    before { allow(Tag).to receive(:search).and_return(records) }

    it "searches with the given args" do
      expect(Tag).to receive(:search).with(args)
      Tag.find(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        expect(Tag.find(args)).to eq record
      end
    end

    context "when no records are returned" do
      before { allow(Tag).to receive(:search).and_return([]) }

      it "raise an exception" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound)
      end

      it "gives the class of the remote record not found in the message" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound, /Tag/)
      end
    end
  end

  describe ".search" do
    let(:serialized_records) { [ Tag.new ] }

    context "given args that respond to :to_hash" do
      let(:args) { Hash.new }
      let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class) }

      before { rpc.better_stub(:execute).and_return(response) }
      before { ::Tag.better_stub(:rpc).and_return(rpc) }

      it "searches with the given args" do
        expect(Tag.rpc).to receive(:execute).with(:search, args)
        Tag.search(args)
      end

      it "returns records" do
        expect(Tag.search(args)).to eq serialized_records
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

    before {
      allow(rpc).to receive(:execute).and_return(response)
      Tag.better_stub(:rpc).and_return(rpc)
    }

    it "runs callbacks" do
      expect(subject).to receive(:run_callbacks).with(:search)
      subject._active_remote_search(args)
    end

    it "executes the search" do
      expect(rpc).to receive(:execute).with(:search, args)
      subject._active_remote_search(args)
    end
  end

  describe "#reload" do
    let(:args) { attributes.slice('guid', 'user_guid') }
    let(:attributes) { HashWithIndifferentAccess.new(:guid => 'foo', :name => 'bar', :updated_at => nil, :user_guid => 'baz') }

    subject { Tag.new(args) }

    before { Tag.better_stub(:find).and_return(attributes) }

    it "reloads the record" do
      Tag.better_receive(:find).with(subject.scope_key_hash)
      subject.reload
    end

    it "assigns new attributes" do
      subject.reload
      expect(subject.attributes).to eq attributes
    end
  end
end
