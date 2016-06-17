require "bigdecimal"
require "bigdecimal/util"
require "active_support/core_ext/big_decimal/conversions"

module ActiveRemote
  module Typecasting
    class BigDecimalTypecaster
      def self.call(value)
        if value.is_a?(BigDecimal)
          value
        elsif value.is_a?(Rational)
          value.to_f.to_d
        elsif value.respond_to?(:to_d)
          value.to_d
        else
          BigDecimal.new(value.to_s)
        end
      end
    end
  end
end
