require "active_support/concern"
require "active_support/core_ext/object/blank"

module ActiveRemote
  # QueryAttributes provides instance methods for querying attributes.
  #
  # @example Usage
  #   class Person < ::ActiveRemote::Base
  #     attribute :name
  #   end
  #
  #   person = Person.new
  #   person.name? #=> false
  #   person.name = "Chris Griego"
  #   person.name? #=> true
  #
  module QueryAttributes
    extend ::ActiveSupport::Concern

    included do
      attribute_method_suffix "?"
    end

    # Test the presence of an attribute
    #
    # See {Typecasting::BooleanTypecaster.call} for more details.
    #
    # @example Query an attribute
    #   person.query_attribute(:name)
    #
    def query_attribute(name)
      if respond_to?("#{name}?")
        send("#{name}?")
      else
        raise ::ActiveRemote::UnknownAttributeError, "unknown attribute: #{name}"
      end
    end

  private

    def attribute?(name)
      ::ActiveRemote::Typecasting::BooleanTypecaster.call(read_attribute(name))
    end
  end
end
