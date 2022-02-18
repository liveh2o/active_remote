module ActiveRemote
  module AttributeMethods
    extend ::ActiveSupport::Concern

    module ClassMethods
      def attribute_names
        @attribute_names ||= attribute_types.keys
      end
    end

    def [](name)
      attribute(name)
    end

    def []=(attr_name, value)
      name = attr_name.to_s
      name = self.class.attribute_aliases[name] || name

      @attributes.write_from_user(name, value)
    end

    # Returns an <tt>#inspect</tt>-like string for the value of the
    # attribute +attr_name+. String attributes are truncated up to 50
    # characters, Date and Time attributes are returned in the
    # <tt>:db</tt> format. Other attributes return the value of
    # <tt>#inspect</tt> without modification.
    #
    #   person = Person.create!(name: 'David Heinemeier Hansson ' * 3)
    #
    #   person.attribute_for_inspect(:name)
    #   # => "\"David Heinemeier Hansson David Heinemeier Hansson ...\""
    #
    #   person.attribute_for_inspect(:created_at)
    #   # => "\"2012-10-22 00:15:07\""
    #
    #   person.attribute_for_inspect(:tag_ids)
    #   # => "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]"
    def attribute_for_inspect(attr_name)
      value = attribute(attr_name)

      if value.is_a?(String) && value.length > 50
        "#{value[0, 50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end

    def attribute_names
      @attributes.keys
    end
  end
end
