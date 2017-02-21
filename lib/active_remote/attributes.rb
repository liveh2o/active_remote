module ActiveRemote
  module Attributes
    extend ::ActiveSupport::Concern
    include ::ActiveModel::AttributeMethods

    included do
      attribute_method_suffix "="
    end

    # Performs equality checking on the result of attributes and its type.
    #
    # @example Compare for equality.
    #   model == other
    #
    def ==(other)
      return false unless other.instance_of?(self.class)
      attributes == other.attributes
    end

    # Returns a copy of our attributes hash
    def attributes
      @attributes.dup
    end

    # Returns the class name plus its attributes
    #
    # @example Inspect the model.
    #   person.inspect
    #
    def inspect
      attribute_descriptions = attributes.sort.map { |key, value| "#{key}: #{value.inspect}" }.join(", ")
      separator = " " unless attribute_descriptions.empty?
      "#<#{self.class.name}#{separator}#{attribute_descriptions}>"
    end

    # Read attribute from the attributes hash
    #
    def read_attribute(name)
      name = name.to_s

      if respond_to? name
        attribute(name)
      else
        raise ::ActiveRemote::UnknownAttributeError, "unknown attribute: #{name}"
      end
    end
    alias_method :[], :read_attribute

    # Update an attribute in the attributes hash
    #
    def write_attribute(name, value)
      name = name.to_s

      if respond_to? "#{name}="
        __send__("attribute=", name, value)
      else
        raise ::ActiveRemote::UnknownAttributeError, "unknown attribute: #{name}"
      end
    end
    alias_method :[]=, :write_attribute

    # Read an attribute from the attributes hash
    #
    def attribute(name)
      @attributes[name]
    end

    # Write an attribute to the attributes hash
    #
    def attribute=(name, value)
      @attributes[name] = value
    end

    def attribute_method?(attr_name)
      # Check if @attributes is defined because dangerous_attribute? method
      # can check allocate.respond_to? before actaully calling initialize
      defined?(@attributes) && @attributes.key?(attr_name)
    end

    module ClassMethods
      # Defines an attribute
      #
      # For each attribute that is defined, a getter and setter will be
      # added as an instance method to the model. An
      # {AttributeDefinition} instance will be added to result of the
      # attributes class method.
      #
      # @example Define an attribute.
      #   attribute :name
      #
      def attribute(name, options={})
        if dangerous_attribute_method_name = dangerous_attribute?(name)
          raise ::ActiveRemote::DangerousAttributeError, %{an attribute method named "#{dangerous_attribute_method_name}" would conflict with an existing method}
        else
          attribute!(name, options)
        end
      end

      # Defines an attribute without checking for conflicts
      #
      # Allows you to define an attribute whose methods will conflict
      # with an existing method. For example, Ruby's Timeout library
      # adds a timeout method to Object. Attempting to define a timeout
      # attribute using .attribute will raise a
      # {DangerousAttributeError}, but .attribute! will not.
      #
      # @example Define a dangerous attribute.
      #   attribute! :timeout
      #
      def attribute!(name, options={})
        ::ActiveRemote::AttributeDefinition.new(name, options).tap do |attribute_definition|
          attribute_name = attribute_definition.name.to_s
          # Force active model to generate attribute methods
          remove_instance_variable("@attribute_methods_generated") if instance_variable_defined?("@attribute_methods_generated")
          define_attribute_methods([attribute_definition.name]) unless attribute_names.include?(attribute_name)
          attributes[attribute_name] = attribute_definition
        end
      end

      # Returns an Array of attribute names as Strings
      #
      # @example Get attribute names
      #   Person.attribute_names
      #
      def attribute_names
        attributes.keys
      end

      # Returns a Hash of AttributeDefinition instances
      #
      # @example Get attribute definitions
      #   Person.attributes
      #
      def attributes
        @attributes ||= ::ActiveSupport::HashWithIndifferentAccess.new
      end

      # Determine if a given attribute name is dangerous
      #
      # Some attribute names can cause conflicts with existing methods
      # on an object. For example, an attribute named "timeout" would
      # conflict with the timeout method that Ruby's Timeout library
      # mixes into Object.
      #
      # @example Testing a harmless attribute
      #   Person.dangerous_attribute? :name #=> false
      #
      # @example Testing a dangerous attribute
      #   Person.dangerous_attribute? :timeout #=> "timeout"
      #
      def dangerous_attribute?(name)
        return false if attribute_names.include?(name.to_s)

        attribute_methods(name).detect do |method_name|
          allocate.respond_to?(method_name, true)
        end
      end

      # Returns the class name plus its attribute names
      #
      # @example Inspect the model's definition.
      #   Person.inspect
      #
      def inspect
        inspected_attributes = attribute_names.sort
        attributes_list = "(#{inspected_attributes.join(", ")})" unless inspected_attributes.empty?
        "#{name}#{attributes_list}"
      end

    protected

      # Assign a set of attribute definitions, used when subclassing models
      #
      def attributes=(attributes)
        @attributes = attributes
      end

    private

      # Expand an attribute name into its generated methods names
      #
      def attribute_methods(name)
        attribute_method_matchers.map { |matcher| matcher.method_name(name) }
      end

      # Ruby inherited hook to assign superclass attributes to subclasses
      #
      def inherited(subclass)
        super
        subclass.attributes = attributes.dup
      end
    end
  end
end
