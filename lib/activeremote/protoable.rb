module Activeremote

	# Provide proto behaviors for a model
	module Protoable
		def self.included(klass)
			klass.extend(::Activeremote::Protoable)
			klass.extend(::Activeremote::Protoable::ClassMethods)
			klass.__send__(:include, ::Activeremote::Protoable::InstanceMethods)

			klass.class_eval do
				class << self
					attr_accessor :_protobuf_columns, :_protobuf_column_types
				end

				@_protobuf_columns = {}
				@_protobuf_column_types = {}
			end

			_protobuf_map_columns(klass)
		end

		# Map out the columns for future reference on type conversion
		def self._protobuf_map_columns(klass)
			klass.columns.map do |column|
				klass._protobuf_columns[column.name.to_sym] = column
				klass._protobuf_column_types[column.type.to_sym] ||= []
				klass._protobuf_column_types[column.type.to_sym] << column.name.to_sym
			end
		end


		def _protobuf_base_model
			@_protobuf_base_model ||= (self.class == Class ? self : self.class)
		end

		module InstanceMethods

			def errors_for_protobuf
				return [] unless errors.any?

				errors.messages.map do |field, error_messages|
					{
						:field => field.to_s,
						:messages => error_messages.dup
					}
				end
			end

			# TODO: Move these status codes to a constant
			def status_code_for_protobuf
				return (errors.any? ? 400 : 200)
			end

		end

		module ClassMethods
			def _int64_to_datetime(protobuf_value)
				return protobuf_value.respond_to?(:to_i) ? Time.at(protobuf_value.to_i) : protobuf_value
			end

			def _protobuf_datetime_column?(key)
				_protobuf_column_types[:datetime] && _protobuf_column_types[:datetime].include?(key)
			end

			def _protobuf_filter_and_convert(key, value)
				column = _protobuf_columns[key]
				value = case
								when _protobuf_datetime_column?(key) then
									_int64_to_datetime(value)
								else
									value
								end

				return value
			end
		end

		def update_hash(protobuf_object)
			updateable_hash = protobuf_object.to_hash.dup
			updateable_hash.select! do |key, value|
				protobuf_object.has_field?(key) && !protobuf_object.get_field(key).repeated?
			end

			updateable_hash.select! do |key, value|
				_protobuf_base_model.column_names.include?(key.to_s)
			end

			updateable_hash.dup.each do |key, value|
				updateable_hash[key] = _protobuf_base_model._protobuf_filter_and_convert(key, value)
			end

			return updateable_hash
		end
		alias_method :create_hash, :update_hash
		alias_method :protobuf_create_hash, :update_hash
		alias_method :protobuf_update_hash, :update_hash

		def respond_to_and_has?(request, key)
			request.respond_to?(key) &&
				request.respond_to?(:has_field?) &&
				request.has_field?(key)
		end
		alias_method :responds_to_and_has?, :respond_to_and_has?

		def respond_to_and_has_and_present?(request, key)
			respond_to_and_has?(request, key) &&
				request.__send__(key).present?
		end
		alias_method :reponds_to_and_has_and_present?, :respond_to_and_has_and_present?

	end

end
