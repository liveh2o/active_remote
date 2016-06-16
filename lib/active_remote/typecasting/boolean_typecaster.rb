module ActiveRemote
  module Typecasting
    class BooleanTypecaster
       FALSE_VALUES = ["n", "N", "no", "No", "NO", "false", "False", "FALSE", "off", "Off", "OFF", "f", "F"]

      def self.call(value)
        case value
        when *FALSE_VALUES then false
        when Numeric, /^\-?[0-9]/ then !value.to_f.zero?
        else value.present?
        end
      end
    end
  end
end
