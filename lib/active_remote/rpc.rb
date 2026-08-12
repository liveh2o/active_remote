require "active_remote/rpc_adapters/protobuf_adapter"
require "active_remote/serializers/protobuf"

module ActiveRemote
  module RPC
    extend ::ActiveSupport::Concern

    included do
      include ::ActiveRemote::Serializers::Protobuf
    end

    module ClassMethods
      # Builds an ActiveModel::AttributeSet from an RPC response, ready to be
      # handed to #init_with.
      def build_from_rpc(values)
        values = values.stringify_keys

        # A shallow dup is enough: every slot is overwritten below, so there is
        # nothing left shared with the defaults.
        attribute_names.each_with_object(_default_attributes.dup) do |name, attributes|
          attributes.write_from_database(name, values[name])
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
      errors.clear
      add_errors(response.errors) if response.respond_to?(:errors)

      # A rejected write echoes back the unchanged record; adopting it would
      # revert the caller's edits and leave nothing to retry with.
      merge_attributes_from_rpc(response.to_hash) if success?

      success?
    end

    def remote_call(rpc_method, request_args)
      self.class.remote_call(rpc_method, request_args)
    end

    def rpc
      self.class.rpc
    end

    private

    # Merged rather than rebuilt, since partial-update endpoints echo back only
    # the fields they touched. The set is replaced rather than mutated so dirty
    # snapshots taken before the call still see the old values.
    def merge_attributes_from_rpc(values)
      values = values.stringify_keys.slice(*self.class.attribute_names)

      @attributes = @attributes.deep_dup.tap do |attributes|
        values.each { |name, value| attributes.write_from_database(name, value) }
      end
    end
  end
end
