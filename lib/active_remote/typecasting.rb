require "active_remote/typecasting/big_decimal_typecaster"
require "active_remote/typecasting/boolean"
require "active_remote/typecasting/boolean_typecaster"
require "active_remote/typecasting/date_time_typecaster"
require "active_remote/typecasting/date_typecaster"
require "active_remote/typecasting/float_typecaster"
require "active_remote/typecasting/integer_typecaster"
require "active_remote/typecasting/object_typecaster"
require "active_remote/typecasting/string_typecaster"

module ActiveRemote
  module Typecasting
    extend ActiveSupport::Concern

    TYPECASTER_MAP = {
      BigDecimal => ::ActiveRemote::Typecasting::BigDecimalTypecaster,
      Boolean => ::ActiveRemote::Typecasting::BooleanTypecaster,
      Date => ::ActiveRemote::Typecasting::DateTypecaster,
      DateTime => ::ActiveRemote::Typecasting::DateTimeTypecaster,
      Float => ::ActiveRemote::Typecasting::FloatTypecaster,
      Integer => ::ActiveRemote::Typecasting::IntegerTypecaster,
      Object => ::ActiveRemote::Typecasting::ObjectTypecaster,
      String => ::ActiveRemote::Typecasting::StringTypecaster
    }.freeze

    private

    def attribute=(name, value)
      return super if value.nil?

      typecaster = _attribute_typecaster(name)
      return super unless typecaster

      super(name, typecaster.call(value))
    end

    def _attribute_typecaster(attribute_name)
      self.class.attributes[attribute_name][:typecaster] || _typecaster_for(attribute_name)
    end

    def _typecaster_for(attribute_name)
      type = self.class.attributes[attribute_name][:type]
      return nil unless type

      TYPECASTER_MAP[type]
    end

    module ClassMethods
      def inspect
        inspected_attributes = attribute_names.sort.map { |name| "#{name}: #{_attribute_type(name)}" }
        attributes_list = "(#{inspected_attributes.join(", ")})" unless inspected_attributes.empty?
        "#{name}#{attributes_list}"
      end

      def _attribute_type(attribute_name)
        attributes[attribute_name][:type] || Object
      end
    end
  end
end
