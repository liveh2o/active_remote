require "active_support/core_ext/hash/keys"

# Added ActiveModel AttributeAssignment to support Rails 4.
# In Rails 5 this is built in to ActiveModel, but our behavior
# in ActiveRemote is different.
module ActiveRemote
  module AttributeAssignment
    include ::ActiveModel::ForbiddenAttributesProtection

    # Allows you to set all the attributes by passing in a hash of attributes with
    # keys matching the attribute names.
    #
    # If the passed hash responds to <tt>permitted?</tt> method and the return value
    # of this method is +false+ an <tt>ActiveModel::ForbiddenAttributesError</tt>
    # exception is raised.
    #
    #   class Cat
    #     include ActiveModel::AttributeAssignment
    #     attr_accessor :name, :status
    #   end
    #
    #   cat = Cat.new
    #   cat.assign_attributes(name: "Gorby", status: "yawning")
    #   cat.name # => 'Gorby'
    #   cat.status => 'yawning'
    #   cat.assign_attributes(status: "sleeping")
    #   cat.name # => 'Gorby'
    #   cat.status => 'sleeping'
    def assign_attributes(new_attributes)
      if !new_attributes.respond_to?(:stringify_keys)
        raise ArgumentError, "When assigning attributes, you must pass a hash as an argument."
      end
      return if new_attributes.nil? || new_attributes.empty?

      attributes = new_attributes.stringify_keys
      _assign_attributes(sanitize_for_mass_assignment(attributes))
    end

    def reset_attributes
      @attributes = self.class.send(:default_attributes_hash).dup
    end

    private

    def _assign_attributes(attributes)
      attributes.each do |name, value|
        _assign_attribute(name, value)
      end
    end

    # ActiveRemote silently ignores unknown attributes, unlike ActiveModel
    # Consider changing ActiveRemote to behave the same
    def _assign_attribute(name, value)
      public_send("#{name}=", value) if respond_to?("#{name}=")
    end
  end
end
