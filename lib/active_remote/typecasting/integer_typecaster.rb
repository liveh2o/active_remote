module ActiveRemote
  module Typecasting
    class IntegerTypecaster
      def self.call(value)
        value.to_i if value.respond_to? :to_i
      rescue FloatDomainError
      end
    end
  end
end
