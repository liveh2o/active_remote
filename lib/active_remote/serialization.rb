module ActiveRemote
  module Serialization

    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Serialization::ClassMethods
        include ActiveRemote::Serialization::InstanceMethods
      end
    end

    module ClassMethods

      private

      ##
      # Recursively build messages from a hash of attributes.
      # TODO need to pull this functionality into the protobuf gem.
      #
      def self.build_message(message_class, attributes)
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

    ##
    # Instance methods
    #
    module InstanceMethods

      # Returns a json representation of the whitelisted publishable attributes.
      def as_json(options = {})
        json_attributes = _publishable_attributes || attributes.keys

        default_options = { :only => json_attributes }
        default_options.merge!(options)

        super(default_options)
      end

      # Returns an array of records that have been endowed with
      # ActiveRemote capabilities via #mimic_response.
      def serialize_records
        last_response.records.map do |record|
          remote = self.class.new(record.to_hash)
          remote.__send__(:mimic_response, record)
          remote
        end
      end

      private

      def build_message(message_class, attributes)
        self.class.build_message(message_class, attributes)
      end

      # Endow a proto object with ActiveRemote capabilities.
      def mimic_response(response)
        response.public_methods(false).each do |method|
          unless respond_to?(method)
            (class << self; self; end).class_eval do
              define_method method do |*args|
                response.__send__(method, *args)
              end
            end
          end
        end
      end

    end

  end
end

