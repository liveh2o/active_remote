require "spec_helper"

describe ::ActiveRemote::RPC do
  subject { ::Tag.new }

  describe ".build_from_rpc" do
    let(:new_attributes) { { :name => "test" } }

    context "missing attributes from rpc" do
      it "initializes to nil" do
        expect(::Tag.build_from_rpc(new_attributes)).to include("guid" => nil)
      end
    end

    context "extra attributes from rpc" do
      let(:new_attributes) { { :foobar => "test" } }

      it "ignores unknown attributes" do
        expect(::Tag.build_from_rpc(new_attributes)).to_not include("foobar" => "test")
      end
    end

    context "typecasted attributes" do
      let(:new_attributes) { { :birthday => "2017-01-01" } }

      it "calls the typecasters" do
        expect(
          ::TypecastedAuthor.build_from_rpc(new_attributes)
        ).to include("birthday" => "2017-01-01".to_datetime)
      end
    end
  end

  describe ".remote_call" do
    let(:args) { double(:args) }
    let(:response) { double(:response) }

    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class, ::Tag.endpoints) }

    before { allow(rpc).to receive(:execute).and_return(response) }
    before { allow(::Tag).to receive(:rpc).and_return(rpc) }

    it "calls the given RPC method" do
      expect(::Tag.rpc).to receive(:execute).with(:remote_method, args)
      ::Tag.remote_call(:remote_method, args)
    end

    it "returns the response" do
      allow(::Tag.rpc).to receive(:execute).and_return(response)
      expect(::Tag.remote_call(:remote_method, args)).to eq response
    end
  end

  describe "#assign_attributes_from_rpc" do
    let(:response) { ::Generic::Remote::Tag.new(:guid => tag.guid, :name => "bar") }
    let(:tag) { ::Tag.new(:guid => SecureRandom.uuid, :name => "foo") }

    it "updates the attributes from the response" do
      expect { tag.assign_attributes_from_rpc(response) }.to change { tag.name }.to(response.name)
    end

    context "when response does not respond to errors" do
      let(:response) { double(:response, :to_hash => ::Hash.new) }

      it "does not add errors from the response" do
        expect { tag.assign_attributes_from_rpc(response) }.to_not change { tag.has_errors? }
      end
    end

    context "when errors are returned" do
      let(:response) {
        ::Generic::Remote::Tag.new(
          :guid => tag.guid,
          :name => "bar",
          :errors => [{ :field => "name", :message => "message" }]
        )
      }

      it "adds errors from the response" do
        expect { tag.assign_attributes_from_rpc(response) }.to change { tag.has_errors? }.to(true)
      end

      it "does not update attributes" do
        expect(tag.name).to eq "foo"
        tag.assign_attributes_from_rpc(response)
        expect(tag.name).to eq "foo"
      end
    end
  end
end
