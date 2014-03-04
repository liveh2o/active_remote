module ActiveRemote
  module PrimaryKey
    extend ActiveSupport::Concern

    module ClassMethods
      def default_primary_key
        [:guid]
      end

      def primary_key(value = nil)
        @primary_key = value if value
        @primary_key ||= default_primary_key
      end
    end

    def primary_key_hash
      [ self.class.primary_key ].flatten.inject({}) { |hash, key| hash.merge({ key => self[key] }) }
    end
  end
end
