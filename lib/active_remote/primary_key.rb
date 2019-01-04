module ActiveRemote
  module PrimaryKey
    extend ActiveSupport::Concern

    module ClassMethods
      ##
      # The default_primary_key is used to define what attribute is used
      # as a primary key for your global code base. If you use a primary
      # key other than this, you'll want to set it using the primary_key
      # method listed below
      #
      def default_primary_key
        :guid
      end

      ##
      # In the event that you use a different primary key than the default
      # primary key listed above (like :uuid, or :id), you'll use this method
      # to change that primary key. This will be used when making remote
      # calls to persist or refresh data.
      #
      def primary_key(value = nil)
        @primary_key = value if value
        @primary_key || default_primary_key
      end
    end

    ##
    # Instance level access to either the default primary key, or whatever
    # you configured the class level primary key to be.
    #
    def primary_key
      self.class.primary_key
    end

    # Returns an Array of all key attributes if any of the attributes is set, whether or not
    # the object is persisted. Returns +nil+ if there are no key attributes.
    #
    #   class Person
    #     include ActiveModel::Conversion
    #     attr_accessor :id
    #
    #     def initialize(id)
    #       @id = id
    #     end
    #   end
    #
    #   person = Person.new(1)
    #   person.to_key # => [1]
    def to_key
      send(primary_key) ? [send(primary_key)] : nil
    end
  end
end
