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

  # A typo in any of these constants raises NameError from the failure callback
  # instead, so callers rescuing the ActiveRemote error never see it.
  describe "service failures" do
    error_class_for_reason = {
      BAD_REQUEST_DATA: ActiveRemote::BadRequestDataError,
      BAD_REQUEST_PROTO: ActiveRemote::BadRequestProtoError,
      SERVICE_NOT_FOUND: ActiveRemote::ServiceNotFoundError,
      METHOD_NOT_FOUND: ActiveRemote::MethodNotFoundError,
      RPC_ERROR: ActiveRemote::RpcError,
      RPC_FAILED: ActiveRemote::RpcFailedError,
      INVALID_REQUEST_PROTO: ActiveRemote::InvalidRequestProtoError,
      BAD_RESPONSE_PROTO: ActiveRemote::BadResponseProtoError,
      UNKNOWN_HOST: ActiveRemote::UnknownHostError,
      IO_ERROR: ActiveRemote::IOError
    }

    # Release the adapter-level double so mock_rpc's stub on the service class
    # is reached through the client delegation.
    before { allow(adapter).to receive(:client).and_call_original }

    error_class_for_reason.each do |reason, error_class|
      it "raises #{error_class} for #{reason}" do
        error = Struct.new(:error_type, :message).new(
          ::Protobuf::Socketrpc::ErrorReason.const_get(reason), "boom"
        )
        mock_rpc(Tag.service_class, :search, error: error)

        expect { adapter.execute(:search, guid: "1") }.to raise_error(error_class, "boom")
      end
    end

    it "falls back to ActiveRemoteError for an unrecognized reason" do
      mock_rpc(Tag.service_class, :search, error: Struct.new(:error_type, :message).new(9999, "boom"))

      expect { adapter.execute(:search, guid: "1") }.to raise_error(ActiveRemote::ActiveRemoteError, "boom")
    end

    it "falls back to ActiveRemoteError when the error has no type" do
      mock_rpc(Tag.service_class, :search, error: Struct.new(:message).new("boom"))

      expect { adapter.execute(:search, guid: "1") }.to raise_error(ActiveRemote::ActiveRemoteError, "boom")
    end
  end
end
