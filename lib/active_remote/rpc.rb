require 'active_remote/serializers/protobuf'

module ActiveRemote
  module RPC
    extend ActiveSupport::Concern

    included do
      include Serializers::Protobuf
    end

    module ClassMethods

      # Execute an RPC call to the remote service and return the raw response.
      #
      def remote_call(rpc_method, request_args)
        rpc.execute(rpc_method, request_args)
      end

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

      # TODO: Make this a first class citizen instead of embedding it inside
      # the remote class
      def rpc
        self.new
      end
    end

    # Invoke an RPC call to the service for the given rpc method.
    #
    def execute(rpc_method, request_args)
      @last_request = request(rpc_method, request_args)

      _service_class.client.__send__(rpc_method, @last_request) do |c|

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

    # Execute an RPC call to the remote service and return the raw response.
    #
    def remote_call(rpc_method, request_args)
      rpc.execute(rpc_method, request_args)
    end

    def rpc
      self.class.rpc
    end

  private

    # Return a protobuf request object for the given rpc call.
    #
    def request(rpc_method, attributes)
      self.class.request(rpc_method, attributes)
    end
  end
end
