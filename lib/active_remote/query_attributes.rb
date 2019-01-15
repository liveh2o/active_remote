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

    def query_attribute(attr_name)
      value = self[attr_name]

      case value
      when true        then true
      when false, nil  then false
      else
        value.present?
      end
    end

  private

    def attribute?(attribute_name)
      query_attribute(attribute_name)
    end
  end
end
