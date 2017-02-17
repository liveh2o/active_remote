require "active_support/concern"
require "active_support/core_ext/object/duplicable"

module ActiveRemote
  # AttributeDefaults allows defaults to be declared for your attributes
  #
  # Defaults are declared by passing the :default option to the attribute
  # class method. If you need the default to be dynamic, pass a lambda, Proc,
  # or any object that responds to #call as the value to the :default option
  # and the result will calculated on initialization. These dynamic defaults
  # can depend on the values of other attributes when those attributes are
  # assigned using MassAssignment or BlockInitialization.
  #
  # @example Usage
  #   class Person
  #     include ActiveRemote::AttributeDefaults
  #
  #     attribute :first_name, :default => "John"
  #     attribute :last_name, :default => "Doe"
  #   end
  #
  #   person = Person.new
  #   person.first_name #=> "John"
  #   person.last_name #=> "Doe"
  #
  # @example Dynamic Default
  #   class Event
  #     include ActiveAttr::MassAssignment
  #     include ActiveRemote::AttributeDefaults
  #
  #     attribute :start_date
  #     attribute :end_date, :default => lambda { start_date }
  #   end
  #
  #   event = Event.new(:start_date => Date.parse("2012-01-01"))
  #   event.end_date.to_s #=> "2012-01-01"
  #
  module AttributeDefaults
    extend ActiveSupport::Concern

    # Applies the attribute defaults
    #
    # Applies all the default values to any attributes not yet set, avoiding
    # any attribute setter logic, such as dirty tracking.
    #
    # @example Usage
    #   class Person
    #     include ActiveRemote::AttributeDefaults
    #
    #     attribute :first_name, :default => "John"
    #   end
    #
    #   person = Person.new
    #   person.first_name #=> "John"
    #
    def apply_defaults(defaults=attribute_defaults)
      @attributes ||= {}
      defaults.each do |name, value|
        # instance variable is used here to avoid any dirty tracking in attribute setter methods
        @attributes[name] = value if @attributes[name].nil?
      end
    end

    # Calculates the attribute defaults from the attribute definitions
    #
    # @example Usage
    #   class Person
    #     include ActiveAttr::AttributeDefaults
    #
    #     attribute :first_name, :default => "John"
    #   end
    #
    #   Person.new.attribute_defaults #=> {"first_name"=>"John"}
    #
    def attribute_defaults
      self.class.attribute_names.inject({}) do |defaults, name|
        defaults[name] = _attribute_default(name)
        defaults
      end
    end

    # Applies attribute default values
    #
    def initialize(*)
      super
      apply_defaults
    end

    private

    # Calculates an attribute default
    #
    def _attribute_default(attribute_name)
      default = self.class.attributes[attribute_name][:default]

      case
      when default.respond_to?(:call) then instance_exec(&default)
      when default.duplicable? then default.dup
      else default
      end
    end
  end
end
