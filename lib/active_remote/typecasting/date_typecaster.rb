module ActiveRemote
  module Typecasting
    class DateTypecaster
      def self.call(value)
        value.to_date if value.respond_to?(:to_date)
      rescue NoMethodError, ArgumentError
      end
    end
  end
end
