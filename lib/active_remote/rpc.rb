require 'active_remote/serializers/protobuf'

module ActiveRemote
  module RPC
    def self.included(klass)
      klass.class_eval do
        extend ::ActiveRemote::RPC::ClassMethods
        include ::ActiveRemote::Serializers::Protobuf
      end
    end

    module ClassMethods

      # Return a protobuf request object for the given rpc request.
      #
      def request(rpc_method, attributes)
        message_class = request_type(rpc_method)
        build_message(message_class, attributes)
      end

      # Return the class applicable to the request for the given rpc method.
      #
      def request_type(rpc_method)
        service_class.rpcs[_service][rpc_method].request_type
      end
    end

    # Invoke an RPC call to the service for the given rpc method.
    # Returns a boolean indicating success or failure.
    #
    def _execute(rpc_method, request_args)
      proto = request(rpc_method, request_args) if request_args.is_a?(Hash)
      @last_request = proto

      _service_class.client.__send__(rpc_method, @last_request) do |c|

        # In the event of service failure, record the error.
        c.on_failure do |error|
          raise ActiveRemoteError, error.message
        end

        # In the event of service success, assign the response, rewrite the
        # @attributes hash, and mixin AR behavior to the response proto.
        c.on_success do |response|
          @last_response = response

          # TODO: this should be consolidated so its not repeated in the constructor
          @attributes = HashWithIndifferentAccess.new(response.to_hash)
          mimic_response(response)
        end
      end
    end

  private

    # Return a protobuf request object for the given rpc call.
    def request(rpc_method, attributes)
      self.class.request(rpc_method, attributes)
    end
  end
end
