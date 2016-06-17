module ActiveRemote
  module Typecasting
    class StringTypecaster
      def self.call(value)
        value.to_s if value.respond_to?(:to_s)
      end
    end
  end
end
