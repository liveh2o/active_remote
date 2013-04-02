require 'protobuf_extensions/base_field'

module ActiveRemote
  module Serializers
    module Protobuf
      ATTRIBUTE_TYPES = {
        ::Protobuf::Field::DoubleField => Float,
        ::Protobuf::Field::FloatField => Float,
        ::Protobuf::Field::Int32Field => Integer,
        ::Protobuf::Field::Int64Field => Integer,
        ::Protobuf::Field::Uint32Field => Integer,
        ::Protobuf::Field::Uint64Field => Integer,
        ::Protobuf::Field::Sint32Field => Integer,
        ::Protobuf::Field::Sint64Field => Integer,
        ::Protobuf::Field::Fixed32Field => Float,
        ::Protobuf::Field::Fixed64Field => Float,
        ::Protobuf::Field::Sfixed32Field => Float,
        ::Protobuf::Field::Sfixed64Field => Float,
        ::Protobuf::Field::StringField => String,
        ::Protobuf::Field::BytesField => String,
        ::Protobuf::Field::BoolField => ::ActiveAttr::Typecasting::Boolean,
        :bool => ::ActiveAttr::Typecasting::Boolean,
        :double => Float,
        :float => Float,
        :int32 => Integer,
        :int64 => Integer,
        :string => String
      }.freeze

      def self.included(klass)
        klass.extend ::ActiveRemote::Serializers::Protobuf::ClassMethods
      end

      module ClassMethods
        # Recursively build messages from a hash of attributes.
        # TODO: Pull this functionality into the protobuf gem.
        #
        def build_message(message_class, attributes)
          attributes.inject(message_class.new) do |message, (key, value)|
            if field = message.get_field_by_name(key) || message.get_ext_field_by_name(key)

              # Override the value based on the field type where issues
              # exist in the protobuf gem.
              #
              if field.repeated?
                collection = [ value ]
                collection.flatten!
                collection.compact!
                collection.map! { |value| coerce(value, field) }
                value = collection
              else
                value = coerce(value, field)
              end

              if field.message? && field.repeated?
                value = value.map do |attributes|
                  attributes.is_a?(Hash) ? build_message(field.type, attributes) : attributes
                end
              elsif field.message?
                value = value.is_a?(Hash) ? build_message(field.type, value) : value
              end

              message.method("#{key}=").call(value)
            end

            message
          end
        end

        def coerce(value, field)
          return value if value.nil?
          return value.to_i if field.enum?

          protobuf_field_type = ::ActiveRemote::Serializers::Protobuf::ATTRIBUTE_TYPES[field.type]

          case 
          when protobuf_field_type == ::ActiveAttr::Typecasting::Boolean then
            if value == 1
              return true
            elsif value == 0
              return false
            end
          when protobuf_field_type == Integer then
            return value.to_i
          when protobuf_field_type == Float then
            return value.to_f
          when protobuf_field_type == String then
            return value.to_s
          end

          return value
        end
      end

      def build_message(message_class, attributes)
        self.class.build_message(message_class, attributes)
      end
    end
  end
end
