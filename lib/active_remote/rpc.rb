require 'active_remote/rpc_adapters/protobuf_adapter'
require 'active_remote/serializers/protobuf'

module ActiveRemote
  module RPC
    extend ::ActiveSupport::Concern

    included do
      include ::ActiveRemote::Serializers::Protobuf
    end

    module ClassMethods

      # Execute an RPC call to the remote service and return the raw response.
      #
      def remote_call(rpc_method, request_args)
        rpc.execute(rpc_method, request_args)
      end

      def rpc
        rpc_adapter.new(service_class)
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

        ::ActiveRemote::RPCAdapters::ProtobufAdapter
      end
    end

    def rpc
      self.class.rpc
    end
  end
end
