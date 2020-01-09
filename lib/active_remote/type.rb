# Based on the type registry from Rails 5.0
# https://github.com/rails/rails/blob/5-0-stable/activemodel/lib/active_model/type.rb
#
# TODO: Replace this with the Active Model type registry once Rails 4.2 support is dropped.
#
require "active_remote/type/registry"
require "active_remote/typecasting"

module ActiveRemote
  module Type
    @registry = Registry.new

    class << self
      attr_accessor :registry # :nodoc:

      # Add a new type to the registry, allowing it to be gotten through ActiveRemote::Type#lookup
      def register(type_name, klass)
        registry.register(type_name, klass)
      end

      def lookup(type_name) # :nodoc:
        registry.lookup(type_name)
      end
    end

    register(:boolean, Typecasting::BooleanTypecaster)
    register(:date, Typecasting::DateTypecaster)
    register(:datetime, Typecasting::DateTimeTypecaster)
    register(:decimal, Typecasting::BigDecimalTypecaster)
    register(:float, Typecasting::FloatTypecaster)
    register(:integer, Typecasting::IntegerTypecaster)
    register(:object, Typecasting::ObjectTypecaster)
    register(:string, Typecasting::StringTypecaster)
    register(:big_integer, Typecasting::IntegerTypecaster)
  end
end
