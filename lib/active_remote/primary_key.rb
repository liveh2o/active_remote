module ActiveRemote
  module PrimaryKey
    extend ActiveSupport::Concern

    module ClassMethods

      def default_primary_key
        [:guid]
      end

      def primary_key(*keys)
        @class_primary_key = keys.empty? ? default_primary_key : keys.flatten
      end

      def class_primary_key
        @class_primary_key || primary_key
      end

    end

    def primary_key_hash
      primary_class_key = self.class.class_primary_key

      primary_class_key.inject({}) { |hash, key| hash.merge({ key => self[key] }) }
    end
  end
end
