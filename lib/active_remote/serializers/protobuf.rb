module ActiveRemote
  module Serializers
    module Protobuf
      extend ActiveSupport::Concern

      TYPECASTER_MAP = {
        ::Protobuf::Field::BoolField     => ActiveAttr::Typecasting::BooleanTypecaster,
        ::Protobuf::Field::BytesField    => ActiveAttr::Typecasting::StringTypecaster,
        ::Protobuf::Field::DoubleField   => ActiveAttr::Typecasting::FloatTypecaster,
        ::Protobuf::Field::Fixed32Field  => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Fixed64Field  => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::FloatField    => ActiveAttr::Typecasting::FloatTypecaster,
        ::Protobuf::Field::Int32Field    => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Int64Field    => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Sfixed32Field => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Sfixed64Field => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Sint32Field   => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Sint64Field   => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::StringField   => ActiveAttr::Typecasting::StringTypecaster,
        ::Protobuf::Field::Uint32Field   => ActiveAttr::Typecasting::IntegerTypecaster,
        ::Protobuf::Field::Uint64Field   => ActiveAttr::Typecasting::IntegerTypecaster
      }

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

        def typecast(value)
          return value if value.nil?

          typecaster? ? typecaster.call(value) : value
        end

        def typecasted_value
          typecast(value)
        end

        def typecaster
          @typecaster ||= begin
            typecaster = TYPECASTER_MAP[field.type_class]
            typecaster.new if typecaster
          end
        end

        def typecaster?
          typecaster.present?
        end
      end
    end
  end
end
