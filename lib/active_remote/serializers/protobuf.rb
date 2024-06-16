module ActiveRemote
  module Serializers
    module Protobuf
      extend ActiveSupport::Concern

      FIELD_TYPE_MAP = {
        ::Protobuf::Field::BoolField => :boolean,
        ::Protobuf::Field::BytesField => :string,
        ::Protobuf::Field::DoubleField => :float,
        ::Protobuf::Field::Fixed32Field => :float,
        ::Protobuf::Field::Fixed64Field => :float,
        ::Protobuf::Field::FloatField => :float,
        ::Protobuf::Field::Int32Field => :integer,
        ::Protobuf::Field::Int64Field => :integer,
        ::Protobuf::Field::Sfixed32Field => :float,
        ::Protobuf::Field::Sfixed64Field => :float,
        ::Protobuf::Field::Sint32Field => :integer,
        ::Protobuf::Field::Sint64Field => :integer,
        ::Protobuf::Field::StringField => :string,
        ::Protobuf::Field::Uint32Field => :integer,
        ::Protobuf::Field::Uint64Field => :integer
      }

      def self.type_name_for_field(field)
        FIELD_TYPE_MAP[field.type_class]
      end

      module ClassMethods
        def fields_from_attributes(message_class, attributes)
          Fields.from_attributes(message_class, attributes)
        end
      end

      def fields_from_attributes(message_class, attributes)
        Fields.from_attributes(message_class, attributes)
      end

      class Fields
        attr_reader :attributes, :message_class

        ##
        # Constructor!
        #
        def initialize(message_class, attributes = {})
          @attributes = attributes
          @message_class = message_class
        end

        ##
        # Class methods
        #
        def self.from_attributes(message_class, attributes)
          fields = new(message_class, attributes)
          fields.from_attributes
        end

        ##
        # Instance methods
        #
        def from_attributes
          attributes.each_with_object({}) do |(key, value), hash|
            field = message_class.get_field(key, true) # Check extension fields, too
            value = Field.from_attribute(field, value) if field

            hash[key] = value
          end
        end
      end

      class Field
        attr_reader :field, :value

        ##
        # Constructor!
        #
        def initialize(field, value)
          @field = field
          @value = value
        end

        ##
        # Class methods
        #
        def self.from_attribute(field, value)
          field = new(field, value)
          field.from_attribute
        end

        ##
        # Instance methods
        #
        def from_attribute
          if field.repeated_message?

            repeated_message_value
          elsif field.message?

            message_value
          elsif field.repeated?

            repeated_value.map { |value| cast(value) }
          else
            cast_value
          end
        end

        private

        def cast(value)
          type.cast(value)
        end

        def cast_value
          cast(value)
        end

        def message_value(attributes = nil)
          attributes ||= value
          attributes.is_a?(Hash) ? Fields.from_attributes(field.type_class, attributes) : attributes
        end

        def repeated_message_value
          repeated_value.map do |attributes|
            message_value(attributes)
          end
        end

        def repeated_value
          value.is_a?(Array) ? value : [value]
        end

        def type
          @type ||= ::ActiveModel::Type.lookup(type_name)
        end

        def type_name
          Serializers::Protobuf.type_name_for_field(field) || :value
        end
      end
    end
  end
end
