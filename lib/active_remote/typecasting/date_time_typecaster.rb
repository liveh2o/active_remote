module ActiveRemote
  module Typecasting
    class DateTimeTypecaster
      def self.call(value)
        value.to_datetime if value.respond_to?(:to_datetime)
      rescue NoMethodError, ArgumentError
      end
    end
  end
end
