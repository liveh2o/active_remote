require 'active_remote/serializers/protobuf'

module ActiveRemote
  module RPCAdapters
    class ProtobufAdapter
      include Serializers::Protobuf

      attr_reader :last_request, :last_response, :service_class

      ##
      # Constructor!
      #
      def initialize(service_class)
        @service_class = service_class
      end

      # Invoke an RPC call to the service for the given rpc method.
      #
      def execute(rpc_method, request_args)
        @last_request = request(rpc_method, request_args)

        service_class.client.__send__(rpc_method, @last_request) do |c|
          # In the event of service failure, raise the error.
          c.on_failure do |error|
            raise ActiveRemoteError, error.message
          end

          # In the event of service success, assign the response.
          c.on_success do |response|
            @last_response = response
          end
        end

        @last_response
      end

      private

      # Return a protobuf request object for the given rpc request.
      #
      def request(rpc_method, request_args)
        return request_args unless request_args.is_a?(Hash)

        message_class = request_type(rpc_method)
        fields = fields_from_attributes(message_class, request_args)
        message_class.new(fields)
      end

      # Return the class applicable to the request for the given rpc method.
      #
      def request_type(rpc_method)
        service_class.rpcs[rpc_method].request_type
      end
    end
  end
end
