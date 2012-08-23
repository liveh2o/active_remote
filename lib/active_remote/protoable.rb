require 'active_remote/protobuf_helpers'
require 'buttress/inheritable_class_instance_variables'

##
# Provide protobuf behaviors for a model
#
module ActiveRemote
  module Protoable
    include ::ActiveRemote::ProtobufHelpers

    def self.included(klass)
      klass.extend(::ActiveRemote::Protoable)
      klass.extend(::ActiveRemote::Protoable::ClassMethods)
      klass.extend(::ActiveRemote::ProtobufHelpers)
      klass.__send__(:include, ::ActiveRemote::ProtobufHelpers)
      klass.__send__(:include, ::ActiveRemote::Protoable::InstanceMethods)
      klass.__send__(:include, ::InheritableClassInstanceVariables)
      klass.__send__(:include, ::Buttress::Failable)

      klass.class_eval do
        class << self
          attr_accessor :_protobuf_columns, :_protobuf_column_types, :_protobuf_column_converters
        end

        @_protobuf_columns = {}
        @_protobuf_column_types = Hash.new { |h,k| h[k] = [] }
        @_protobuf_column_converters = {}

        # NOTE: Make sure each inherited object has the database layout
        inheritable_attributes :_protobuf_columns, :_protobuf_column_types, :_protobuf_column_converters
      end

      _protobuf_map_columns(klass)
      _protobuf_define_ar_castable(klass)
    end

    def self._protobuf_define_ar_castable(klass)
      klass.class_eval do

        # Define a column conversion from protobuf to db. Accepts a callable,
        # Symbol, or Hash.
        #
        # When given a callable, it is directly used to convert the field.
        #
        # When a Hash is given, :from and :to keys are expected and expand
        # to extracting a class method in the format of
        # "_convert_#{from}_to_#{to}".
        #
        # When a symbol is given, it extracts the method with the same name,
        # if any. When method is not available it is assumed as the "from"
        # data type, and the "to" value is extracted based on the
        # name of the column.
        #
        # Examples:
        #   proto_column_convert :created_at, :int64
        #   proto_column_convert :public_key, method(:extract_public_key_from_proto)
        #   proto_column_convert :public_key, :extract_public_key_from_proto
        #   proto_column_convert :status, lambda { |proto_field| ... }
        #   proto_column_convert :symmetric_key, :base64
        #   proto_column_convert :symmetric_key, :from => :base64, :to => :encoded_string
        #   proto_column_convert :symmetric_key, :from => :base64, :to => :raw_string
        #
        def self.proto_column_convert(field, callable = nil, &blk)
          callable ||= blk

          if callable.is_a?(Hash)
            callable = :"_convert_#{callable[:from]}_to_#{callable[:to]}"
          end

          if callable.is_a?(Symbol)
            unless self.respond_to?(callable)
              column = _protobuf_columns[field.to_sym]
              callable = :"_convert_#{callable}_to_#{column.try(:type)}"
            end
            callable = method(callable) if self.respond_to?(callable)
          end

          raise 'Protobuf activerecord casting needs a callable or block!' if callable.nil?
          raise 'Protobuf activerecord casting callable must respond to :call!' if !callable.respond_to?(:call)

          _protobuf_column_converters[field.to_sym] = callable
        end
      end
    end

    # Map out the columns for future reference on type conversion
    def self._protobuf_map_columns(klass)
      return unless klass.table_exists?
      klass.columns.map do |column|
        klass._protobuf_columns[column.name.to_sym] = column
        klass._protobuf_column_types[column.type.to_sym] << column.name.to_sym
      end
    end

    module InstanceMethods

      # Attempt to soft-delete the record by setting is_deleted/deleted_at
      # or status. If none of those fields exist, destroy the record.
      def delete_from_proto
        if respond_to?("is_deleted=")
          attrs = { :is_deleted => true }
          attrs[:deleted_at] = Time.now.utc if respond_to?("deleted_at=")
          update_attributes(attrs)
        elsif respond_to?("status=")
          # TODO remove the status check once statuses are gone-zo.
          #  and make brandon do it.
          update_attribute(:status, ::Atlas::StatusType::DELETED.value)
        else
          destroy_from_proto
        end
      end

      def destroy_from_proto
        destroy
      end

      def errors_for_protobuf
        return [] if valid?

        errors.messages.map do |field, error_messages|
          {
            :field => field.to_s,
            :messages => error_messages.dup
          }
        end
      end

      # TODO: Do we really need to send the name of the status as the message?
      # If the consumer can understand protobuf messages, it can map an enum...
      def record_status_for_protobuf
        if status.present?
          return ::Atlas::Status.new(:status => status, :message => record_status_message)
        end
      end

      def record_status_message
        return ::Atlas::StatusType.name_by_value(status).to_s
      end

      # TODO: Move these status codes to a constant
      def status_code_for_protobuf
        return valid? ? 200 : 400
      end

      def base64_encoded_value_for_protobuf(attr_key)
        value = read_attribute(attr_key)
        if value.present?
          return {
            :encoded => value,
            :raw => self.class._base64_to_bytes(value)
          }
        end
      end

      def update_from_proto(proto)
        updated_attributes = update_hash(proto)
        yield(updated_attributes) if block_given?

        assign_attributes(updated_attributes)
        return valid? ? save! : false
      end
    end

    module ClassMethods
      def create_all_from_protos(*protos)
        protos.flatten!

        process_protos(protos) do |proto|
          _protobuf_base_model.create_from_proto(proto)
        end
      end

      def create_from_proto(proto)
        create_attributes = protobuf_create_hash(proto)
        record = _protobuf_base_model.new(create_attributes)

        record.save! if record.valid?
        return record
      end

      def delete_all_from_protos(*protos)
        protos.flatten!

        find_and_process_protos(protos) do |record, proto|
          record.delete_from_proto
        end
      end

      def destroy_all_from_protos(*protos)
        protos.flatten!

        find_and_process_protos(protos) do |record, proto|
          record.destroy_from_proto
        end
      end

      def update_all_from_protos(*protos)
        protos.flatten!

        find_and_process_protos(protos) do |record, proto|
          record.update_from_proto(proto)
        end
      end

      def find_and_process_protos(*protos)
        protos = protos.flatten.compact.uniq
        hashed_records = _protobuf_base_model.records_hashed_by_guid_from_protos(protos)

        process_protos(protos) do |proto|
          if record = hashed_records[proto.guid]
            yield(record, proto)
          else
            proto.status_code = 404
          end

          record || proto # can't use an explicit return in a block
        end
      end

      # TODO: this might need to be overreaching a bit to require a by_guid scope
      # maybe it should be more configurable?
      def guid_scope(value = nil)
        @guid_scope = value if value
        @guid_scope ||= :by_guid
        return @guid_scope
      end

      def process_protos(protos)
        protos = protos.flatten.compact.uniq
        processed_protos = []

        protos.each do |proto|
          begin
            new_record_hash = proto.to_hash
            record_or_proto = yield(proto)
            record_hash = record_or_proto_to_hash(record_or_proto)
            new_record_hash.merge!(record_hash)
          rescue => e
            new_record_hash[:status_code] = 500
            failed(e, binding, new_record_hash)
          ensure
            processed_protos << proto.class.new(new_record_hash)
          end
        end

        processed_protos
      end

      def record_or_proto_to_hash(record_or_proto)
        record_or_proto.respond_to?(:to_proto_hash) ? record_or_proto.to_proto_hash : record_or_proto.to_hash
      end

      def records_hashed_by_guid_from_protos(protos)
        guids = protos.map(&:guid).uniq.compact
        records_hashed_by_guid = {}

        _protobuf_base_model.__send__(guid_scope, guids).find_each do |record|
          records_hashed_by_guid.merge!({ record.guid => record })
        end

        return records_hashed_by_guid
      end

      def _convert_int64_to_datetime(protobuf_value)
        return protobuf_value.respond_to?(:to_i) ? Time.at(protobuf_value.to_i) : protobuf_value
      end

      def _protobuf_date_column?(key)
        _protobuf_column_types[:date] && _protobuf_column_types[:date].include?(key)
      end

      def _protobuf_datetime_column?(key)
        _protobuf_column_types[:datetime] && _protobuf_column_types[:datetime].include?(key)
      end

      def _protobuf_timestamp_column?(key)
        _protobuf_column_types[:timestamp] && _protobuf_column_types[:timestamp].include?(key)
      end

      def _protobuf_time_column?(key)
        _protobuf_column_types[:time] && _protobuf_column_types[:time].include?(key)
      end

      def _convert_base64_to_encoded_string(field)
        if field.key?(:encoded)
          field[:encoded]
        elsif field.key?(:raw)
          _bytes_to_base64(field[:raw])
        end
      end
      alias_method :convert_base64_to_string, :_convert_base64_to_encoded_string

      def _convert_base64_to_raw_string(field)
        if field.key?(:raw)
          field[:raw]
        elsif field.key?(:encoded)
          _base64_to_bytes(field[:encoded])
        end
      end

      def _base64_to_bytes(encoded)
        Base64.strict_decode64(encoded)
      end

      def _bytes_to_base64(bytes)
        Base64.strict_encode64(bytes)
      end

      def convert_atlas_status_type(val)
        return val.try(:[], :status)
      end

      def _protobuf_filter_and_convert(key, value)
        column = _protobuf_columns[key]
        value = case
                when _protobuf_datetime_column?(key) then
                  _convert_int64_to_datetime(value)
                when _protobuf_timestamp_column?(key) then
                  _convert_int64_to_datetime(value)
                when _protobuf_time_column?(key) then
                  _convert_int64_to_datetime(value)
                when _protobuf_date_column?(key) then
                  _convert_int64_to_datetime(value)
                when _protobuf_column_converters.has_key?(key.to_sym) then
                  _protobuf_column_converters[key.to_sym].call(value)
                else
                  value
                end

        return value
      end

      # Method that returns the scope based on the fields that are present
      # in the protobuf.
      #
      # Only works if scopes are named with convention of "by_#{field_name}"
      def scope_from_search_proto(search_scope, proto, *field_symbols)
        field_symbols.flatten.each do |field|
          if responds_to_and_has_and_present?(proto, field)
            search_scope = search_scope.__send__("by_#{field}", proto.__send__(field))
          end
        end

        return search_scope
      end
    end

    def _protobuf_base_model
      @_protobuf_base_model ||= (self.class == Class ? self : self.class)
    end

    def update_hash(protobuf_object)
      updateable_hash = protobuf_object.to_hash.dup

      updateable_hash.select! do |key, value|
        respond_to_and_has?(protobuf_object, key) && !protobuf_object.get_field(key).repeated?
      end

      updateable_hash.select! do |key, value|
        _protobuf_base_model.column_names.include?(key.to_s)
      end

      updateable_hash.dup.each do |key, value|
        updateable_hash[key] = _protobuf_base_model._protobuf_filter_and_convert(key, value)
      end

      return updateable_hash
    end

    ##
    # Instance Aliases
    #
    alias_method :create_hash, :update_hash
    alias_method :protobuf_create_hash, :update_hash
    alias_method :protobuf_update_hash, :update_hash
    alias_method :responds_to_and_has?, :respond_to_and_has?
    alias_method :responds_to_and_has_and_present?, :respond_to_and_has_and_present?

  end

end
