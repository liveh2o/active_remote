module ActiveRemote
  module Attributes
    # Read attribute from the attributes hash
    #
    def read_attribute(name)
      name = name.to_s

      if respond_to? name
        @attributes[name]
      else
        raise ::ActiveAttr::UnknownAttributeError, "unknown attribute: #{name}"
      end
    end
    alias_method :[], :read_attribute

    # Update an attribute in the attributes hash
    #
    def write_attribute(name, value)
      name = name.to_s

      if respond_to? "#{name}="
        @attributes[name] = typecast_attribute(_attribute_typecaster(name), value)
      else
        raise ::ActiveAttr::UnknownAttributeError, "unknown attribute: #{name}"
      end
    end
    alias_method :[]=, :write_attribute
  end
end
