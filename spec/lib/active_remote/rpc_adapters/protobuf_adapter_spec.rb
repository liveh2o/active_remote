require "spec_helper"

RSpec.describe ActiveRemote::RPCAdapters::ProtobufAdapter do
  let(:adapter) { ActiveRemote::RPCAdapters::ProtobufAdapter.new(Tag.service_class, Tag.endpoints) }
  let(:client) { double(:client) }

  subject { adapter }

  # The Protobuf RPC client relies on method missing and delegations
  # Provide a client double to make it possible to add expectations that specific methods are called
  before { allow(adapter).to receive(:client).and_return(client) }

  describe "#execute" do
    context "when a custom endpoint is defined" do
      before { adapter.endpoints[:create] = :register }
      after { adapter.endpoints[:create] = :create }

      it "calls the custom endpoint" do
        expect(adapter.client).to receive(:register)
        adapter.execute(:create, name: "foo")
      end
    end
  end
end
