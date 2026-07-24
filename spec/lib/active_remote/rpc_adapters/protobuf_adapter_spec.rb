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

    # Stands in for the client's callback registry so the real blocks run.
    let(:failing_client) do
      Class.new do
        def initialize(error)
          @error = error
        end

        def on_failure(&block)
          @on_failure = block
        end

        def on_success(&block)
        end

        def method_missing(_name, _request)
          yield self
          @on_failure.call(@error)
        end

        def respond_to_missing?(*)
          true
        end
      end
    end

    error_class_for_reason.each do |reason, error_class|
      it "raises #{error_class} for #{reason}" do
        error = Struct.new(:error_type, :message).new(
          ::Protobuf::Socketrpc::ErrorReason.const_get(reason), "boom"
        )
        allow(adapter).to receive(:client).and_return(failing_client.new(error))

        expect { adapter.execute(:search, guid: "1") }.to raise_error(error_class, "boom")
      end
    end

    it "falls back to ActiveRemoteError for an unrecognized reason" do
      error = Struct.new(:error_type, :message).new(9999, "boom")
      allow(adapter).to receive(:client).and_return(failing_client.new(error))

      expect { adapter.execute(:search, guid: "1") }.to raise_error(ActiveRemote::ActiveRemoteError, "boom")
    end

    it "falls back to ActiveRemoteError when the error has no type" do
      error = Struct.new(:message).new("boom")
      allow(adapter).to receive(:client).and_return(failing_client.new(error))

      expect { adapter.execute(:search, guid: "1") }.to raise_error(ActiveRemote::ActiveRemoteError, "boom")
    end
  end
end
