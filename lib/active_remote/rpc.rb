require "active_remote/rpc_adapters/protobuf_adapter"
require "active_remote/serializers/protobuf"

module ActiveRemote
  module RPC
    extend ::ActiveSupport::Concern

    included do
      include ::ActiveRemote::Serializers::Protobuf
    end

    module ClassMethods
      # Builds an attribute hash that be assigned directly
      # to an object from an rpc response
      def build_from_rpc(values)
        values = values.stringify_keys

        attributes.inject({}) do |attributes, (name, definition)|
          attributes[name] = definition.from_rpc(values[name])
          attributes
        end
      end

      # Execute an RPC call to the remote service and return the raw response.
      #
      def remote_call(rpc_method, request_args)
        rpc.execute(rpc_method, request_args)
      end

      def rpc
        rpc_adapter.new(service_class, endpoints)
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

    def assign_attributes_from_rpc(response)
      unless response.respond_to?(:errors) && response.errors.count > 0
        new_attributes = self.class.build_from_rpc(response.to_hash)
        @attributes.update(new_attributes)
      end

      add_errors(response.errors) if response.respond_to?(:errors)
    end

    def remote_call(rpc_method, request_args)
      self.class.remote_call(rpc_method, request_args)
    end

    def rpc
      self.class.rpc
    end
  end
end
