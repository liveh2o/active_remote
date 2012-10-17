require 'protobuf_extensions/base_field'

module ActiveRemote
  module Serializers
    module Protobuf
      def self.included(klass)
        klass.extend ::ActiveRemote::Serializers::Protobuf::ClassMethods
      end

      module ClassMethods
        # Recursively build messages from a hash of attributes.
        # TODO: Pull this functionality into the protobuf gem.
        #
        def build_message(message_class, attributes)
          attributes.inject(message_class.new) do |message, (key, value)|
            if field = message.get_field(key)

              # Override the value based on the field type where issues
              # exist in the protobuf gem.
              #
              if field.repeated?
                collection = [ value ].flatten
                collection.map! { |value| coerce(value, field) }
                value = collection
              else
                value = coerce(value, field)
              end

              if field.message? && field.repeated?
                value = value.map do |attributes|
                  attributes.is_a?(Hash) ? build_message(field.type, attributes) : attributes
                end
              elsif field.message?
                value = value.is_a?(Hash) ? build_message(field.type, value) : value
              end

              message.method("#{key}=").call(value)
            end

            message
          end
        end

        def coerce(value, field)
          return value if value.nil?
          return value.to_i if field.enum?

          case field.type
          when :bool then
            if value == 1
              return true
            elsif value == 0
              return false
            end
          when /int/ then
            return value.to_i
          when :double then
            return value.to_f
          when :string then
            return value.to_s
          end

          return value
        end
      end

      def build_message(message_class, attributes)
        self.class.build_message(message_class, attributes)
      end
    end
  end
end
