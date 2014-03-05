module ActiveRemote
  module ScopeKeys
    extend ActiveSupport::Concern

    included do
      include PrimaryKey
    end

    module ClassMethods
      def _scope_keys
        @_scope_keys ||= []
      end

      def scope_key(*keys)
        _scope_keys += keys.map(&:to_s)
      end

      def scope_keys
        [ primary_key.to_s ] + _scope_keys
      end
    end

    def scope_keys
      @scope_keys ||= self.class.scope_keys
    end

    def scope_key_hash
      attributes.slice(*scope_keys)
    end
  end
end
