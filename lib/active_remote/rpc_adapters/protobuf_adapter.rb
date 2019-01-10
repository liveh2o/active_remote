require "active_remote/serializers/protobuf"

module ActiveRemote
  module RPCAdapters
    class ProtobufAdapter
      include Serializers::Protobuf

      attr_reader :service_class
      attr_accessor :endpoints

      delegate :client, :to => :service_class

      ##
      # Constructor!
      #
      def initialize(service_class, endpoints)
        @service_class = service_class
        @endpoints = endpoints
      end

      # Invoke an RPC call to the service for the given rpc method.
      #
      def execute(endpoint, request_args)
        rpc_method = endpoints.fetch(endpoint) { endpoint }
        request = build_request(rpc_method, request_args)
        response = nil

        client.send(rpc_method, request) do |c|
          # In the event of service failure, raise the error.
          c.on_failure do |error|
            protobuf_error = protobuf_error_class(error)
            raise protobuf_error, error.message
          end

          # In the event of service success, assign the response.
          c.on_success do |rpc_response|
            response = rpc_response
          end
        end

        response
      end

    private

      # Return a protobuf request object for the given rpc request.
      #
      def build_request(rpc_method, request_args)
        return request_args unless request_args.is_a?(Hash)

        message_class = request_type(rpc_method)
        fields = fields_from_attributes(message_class, request_args)
        message_class.new(fields)
      end

      def protobuf_error_class(error)
        return ::ActiveRemote::ActiveRemoteError unless error.respond_to?(:error_type)

        case error.error_type
        when ::Protobuf::Socketrpc::ErrorReason::BAD_REQUEST_DATA
          ::ActiveRemote::BadRequestDataError
        when ::Protobuf::Socketrpc::ErrorReason::BAD_REQUEST_PROTO
          ::ActiveRemote::BadRequestProtoError
        when ::Protobuf::Socketrpc::ErrorReason::SERVICE_NOT_FOUND
          ::ActiveRemote::ServiceNotFoundError
        when ::Protobuf::Socketrpc::ErrorReason::METHOD_NOT_FOUND
          ::ActiveRemote::MethodNotFoundError
        when ::Protobuf::Socketrpc::ErrorReason::RPC_ERROR
          ::ActiveRemote::RpcError
        when ::Protobuf::Socketrpc::ErrorReason::RPC_FAILED_ERROR
          ::ActiveRemote::RpcFailedError
        when ::Protobuf::Socketrpc::ErrorReason::INVALID_REQUEST_PROTO
          ::ActiveRemote::InvalidRequestProtoError
        when ::Protobuf::Socketrpc::ErrorReason::BAD_RESPONSE_PROTO
          ::ActiveRemote::BadResponseProtoError
        when ::Protobuf::Socketrpc::ErrorReason::UNKNOWN_HOST
          ::ActiveRemote::UnknownHostError
        when ::Protobuf::Socketrpc::ErrorReason::IO_ERROR
          ::ActiveRemote::IOError
        else
          ::ActiveRemote::ActiveRemoteError
        end
      end

      # Return the class applicable to the request for the given rpc method.
      #
      def request_type(rpc_method)
        service_class.rpcs[rpc_method].request_type
      end
    end
  end
end
