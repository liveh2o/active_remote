require 'spec_helper'

describe ::ActiveRemote::RPC do
  subject { ::Tag.new }

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
