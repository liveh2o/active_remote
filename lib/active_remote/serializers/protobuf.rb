module ActiveRemote
  module Serializers
    module Protobuf
      module ClassMethods
        # Recursively build messages from a hash of attributes.
        # TODO: Need to pull this functionality into the protobuf gem.
        #
        def build_message(message_class, attributes)
          attributes.inject(message_class.new) do |message, (key, value)|
            if field = message.get_field(key)

              # Override the value based on the field type where issues
              # exist in the pb gem.
              # FIXME this needs to be removed and/or sucked into the pb gem.
              if field.repeated?
                value = [ value ].flatten
              elsif field.enum?
                value = value.to_i
              else
                case field.type
                when :bool then
                  if value == 1
                    value = true
                  elsif value == 0
                    value = false
                  end
                when /int/ then
                  value = value.to_i
                when :double then
                  value = value.to_f
                when :string then
                  value = value.to_s
                end
              end

              # FIXME not sure how this is even working
              if field.message? && field.repeated?
                value = value.map do |attributes|
                  build_message(field.type, attributes)
                end
              elsif field.message?
                value = build_message(field.type, value)
              end

              message.method("#{key}=").call(value)
            end

            message
          end
        end
      end

      def build_message(message_class, attributes)
        self.class.build_message(message_class, attributes)
      end
    end
  end
end
