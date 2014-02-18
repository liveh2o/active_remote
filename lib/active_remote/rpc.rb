module ActiveRemote
  module RPC
    def self.included(klass)
      klass.class_eval do
        extend ::ActiveRemote::RPC::ClassMethods
      end
    end

    module ClassMethods
      # Execute an RPC call to the remote service and return the raw response.
      #
      def remote_call(rpc_method, request_args)
        remote = self.new
        remote.execute(rpc_method, request_args)
        remote.last_response
      end

      # Return a protobuf request object for the given rpc request.
      #
      def request(rpc_method, request_args)
        return request_args unless request_args.is_a?(Hash)

        request_type(rpc_method).new(request_args)
      end

      # Return the class applicable to the request for the given rpc method.
      #
      def request_type(rpc_method)
        service_class.rpcs[rpc_method].request_type
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
    end

    # Execute an RPC call to the remote service and return the raw response.
    #
    def remote_call(rpc_method, request_args)
      self.execute(rpc_method, request_args)
      self.last_response
    end

  private

    # Return a protobuf request object for the given rpc call.
    #
    def request(rpc_method, attributes)
      self.class.request(rpc_method, attributes)
    end
  end
end
