require "spec_helper"

RSpec.describe ActiveRemote::Search do
  let(:records) { [Generic::Remote::Tag.new(guid: "123")] }
  let(:response) { Generic::Remote::Tags.new(records: records) }
  let(:rpc) { double(:rpc) }

  describe ".find" do
    let(:args) { {} }
    let(:record) { double(:record) }
    let(:records) { [record] }

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

  describe ".find_by" do
    let(:args) { {} }
    let(:record) { double(:record) }
    let(:records) { [record] }

    before { allow(Tag).to receive(:search).and_return(records) }

    it "searches with the given args" do
      expect(Tag).to receive(:search).with(args)
      Tag.find_by(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        expect(Tag.find_by(args)).to eq record
      end
    end

    context "when no records are returned" do
      before { allow(Tag).to receive(:search).and_return([]) }

      it "returns nil" do
        expect(Tag.find_by(args)).to be_nil
      end
    end
  end

  describe ".search" do
    let(:serialized_records) { [Tag.instantiate(guid: "123")] }

    context "given args that respond to :to_hash" do
      let(:args) { {} }
      let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class, ::Tag.endpoints) }

      before { allow(rpc).to receive(:execute).and_return(response) }
      before { allow(::Tag).to receive(:rpc).and_return(rpc) }

      it "searches with the given args" do
        expect(Tag.rpc).to receive(:execute).with(:search, args)
        Tag.search(args)
      end

      it "returns records" do
        records = Tag.search(args)
        expect(records).to eq serialized_records
      end
    end

    context "given args that don't respond to :to_hash" do
      let(:request) { double(:request) }

      it "raises an exception" do
        expect { Tag.search(request) }.to raise_error(::RuntimeError, /Invalid parameter/)
      end
    end
  end

  describe "#reload" do
    let(:args) { attributes.slice("guid", "user_guid") }
    let(:attributes) { HashWithIndifferentAccess.new(guid: "foo", name: "bar", updated_at: nil, user_guid: "baz") }

    subject { Tag.new(args) }

    before { allow(Tag).to receive(:find).and_return(Tag.new(attributes)) }

    it "reloads the record" do
      expect(Tag).to receive(:find).with(subject.scope_key_hash)
      subject.reload
    end

    it "assigns new attributes" do
      subject.reload
      expect(subject.attributes).to eq attributes
    end
  end
end
