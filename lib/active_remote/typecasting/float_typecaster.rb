module ActiveRemote
  module Typecasting
    class FloatTypecaster
      def self.call(value)
        value.to_f if value.respond_to? :to_f
      end
    end
  end
end
