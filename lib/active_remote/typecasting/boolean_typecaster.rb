module ActiveRemote
  module Typecasting
    class BooleanTypecaster
      BOOL_VALUES = [true, false].freeze
      FALSE_VALUES = ["n", "N", "no", "No", "NO", "false", "False", "FALSE", "off", "Off", "OFF", "f", "F"]

      def self.call(value)
        return value if BOOL_VALUES.include?(value)

        case value
        when *FALSE_VALUES then false
        when Numeric, /^\-?[0-9]/ then !value.to_f.zero?
        else value.present?
        end
      end
    end
  end
end
