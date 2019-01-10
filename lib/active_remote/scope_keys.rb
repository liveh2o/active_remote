module ActiveRemote
  module ScopeKeys
    extend ActiveSupport::Concern

    included do
      include PrimaryKey

      class_attribute :_scope_keys
      self._scope_keys = []
    end

    module ClassMethods
      ##
      # Allows you to define, at a class level, what keys should be
      # used as identifiers when making remote calls. For instance,
      #
      # class Tag < ActiveRemote::Base
      #   scope_key :user_guid
      # end
      #
      # When #scope_keys is called on Tag, it will return the primary
      # key in addition to :user_guid as the scope keys.
      #
      def scope_key(*keys)
        self._scope_keys += keys.map(&:to_s)
      end

      ##
      # Used to define what keys are required when making remote
      # persistence or refresh calls.
      #
      def scope_keys
        [primary_key.to_s] + _scope_keys
      end
    end

    ##
    # Instance level access to the scope key of the current class
    #
    def scope_keys
      @scope_keys ||= self.class.scope_keys
    end

    ##
    # Instance level hash of scope keys and their corresponding
    # values. For instance,
    #
    # class Tag < ActiveRemote::Base
    #   scope_key :user_guid
    # end
    #
    # would return this hash:
    #
    # {
    #   :guid      => tag[:guid],
    #   :user_guid => tag[:user_guid]
    # }
    #
    # This hash is used when accessing or modifying a remote object
    # like when calling #update in the persistence module, for example.
    def scope_key_hash
      attributes.slice(*scope_keys)
    end
  end
end
