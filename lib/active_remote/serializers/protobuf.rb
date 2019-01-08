require "active_remote/type"

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
          fields = self.new(message_class, attributes)
          fields.from_attributes
        end

        ##
        # Instance methods
        #
        def from_attributes
          attributes.inject({}) do |hash, (key, value)|
            field = message_class.get_field(key, true) # Check extension fields, too
            value = Field.from_attribute(field, value) if field

            hash[key] = value
            hash
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
          field = self.new(field, value)
          field.from_attribute
        end

        ##
        # Instance methods
        #
        def from_attribute
          case
          when field.repeated_message? then
            repeated_message_value
          when field.message? then
            message_value
          when field.repeated? then
            repeated_value.map { |value| typecast(value) }
          else
            typecasted_value
          end
        end

      private

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
          value.is_a?(Array) ? value : [ value ]
        end

        def type_name
          Serializers::Protobuf.type_name_for_field(field)
        end

        def typecast(value)
          return value if value.nil?

          typecaster? ? typecaster.call(value) : value
        end

        def typecasted_value
          typecast(value)
        end

        def typecaster
          return nil if type_name.nil?

          @typecaster ||= Type.lookup(type_name)
        end

        def typecaster?
          typecaster.present?
        end
      end
    end
  end
end
