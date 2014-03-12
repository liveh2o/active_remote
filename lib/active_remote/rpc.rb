require 'active_remote/rpc_adapters/protobuf_adapter'
require 'active_remote/serializers/protobuf'

module ActiveRemote
  module RPC
    extend ActiveSupport::Concern

    included do
      include Embedded
    end

    module Embedded
      extend ActiveSupport::Concern

      included do
        include Serializers::Protobuf
      end

      module ClassMethods
        # :noapi:
        def request(rpc_method, request_args)
          warn "DEPRECATED Model.request is deprecated and will be removed in Active Remote 3.0. This is handled by the Protobuf RPC adpater now"

          return request_args unless request_args.is_a?(Hash)

          message_class = request_type(rpc_method)
          fields = fields_from_attributes(message_class, request_args)
          message_class.new(fields)
        end

        # :noapi:
        def request_type(rpc_method)
          warn "DEPRECATED Model.request_type is deprecated and will be removed in Active Remote 3.0. This is handled by the Protobuf RPC adpater now"

          service_class.rpcs[rpc_method].request_type
        end
      end

      # :noapi:
      def execute(rpc_method, request_args)
        warn "DEPRECATED Model#execute is deprecated and will be removed in Active Remote 3.0. Use Model#rpc.execute instead"

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

      # :noapi:
      def remote_call(rpc_method, request_args)
        warn "DEPRECATED Model#remote_call is deprecated and will be removed in Active Remote 3.0. Use Model#rpc.execute instead"

        rpc.execute(rpc_method, request_args)
      end

      private

      # :noapi:
      def request(rpc_method, attributes)
        warn "DEPRECATED Model#request is deprecated and will be removed in Active Remote 3.0. This is handled by the Protobuf RPC adpater now"

        self.class.request(rpc_method, attributes)
      end
    end

    module ClassMethods

      # Execute an RPC call to the remote service and return the raw response.
      #
      def remote_call(rpc_method, request_args)
        rpc.execute(rpc_method, request_args)
      end

      def rpc
        @rpc ||= rpc_adapter.new(service_class)
      end

      def rpc_adapter
        # TODO: Make this pluggable
        #
        # raise(AdapterNotSpecified, "configuration does not specify adapter") unless adapter.present?
        #
        # path_to_adapter = "active_remote/rpc_adapters/#{adapter}_adapter"
        #
        # begin
        #   require path_to_adapter
        # rescue Gem::LoadError => e
        #   raise Gem::LoadError, "Specified '#{adapter]}' for RPC adapter, but the gem is not loaded. Add `gem '#{e.name}'` to your Gemfile (and ensure its version is at the minimum required by ActiveRemote)."
        # rescue LoadError => e
        #   raise LoadError, "Could not load '#{path_to_adapter}'. Make sure that the adapter is valid. If you use an adapter other than 'protobuf' add the necessary adapter gem to the Gemfile.", e.backtrace
        # end
        #
        # path_to_adapter.classify.constantize

        RPCAdapters::ProtobufAdapter
      end
    end

    def rpc
      self.class.rpc
    end
  end
end
