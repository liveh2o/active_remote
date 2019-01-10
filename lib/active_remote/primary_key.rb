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
  end
end
