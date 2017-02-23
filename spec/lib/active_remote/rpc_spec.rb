require 'spec_helper'

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

    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class) }

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
end
