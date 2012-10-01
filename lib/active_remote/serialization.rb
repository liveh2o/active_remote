require 'active_remote/serializers/json'

module ActiveRemote
  module Serialization
    def self.included(klass)
      klass.class_eval do
        include ::ActiveRemote::Serializers::JSON
      end
    end

    # Examine the last response and add any errors to our internal errors
    # list.
    #
    def add_errors_from_response
      return unless last_response.respond_to?(:errors)

      last_response.errors.each do |error|
        if error.respond_to?(:message)
          errors.add(error.field, error.message)
        elsif error.respond_to?(:messages)
          error.messages.each do |message|
            errors.add(error.field, message)
          end
        end
      end
    end

    # Examine the last response and serialize any records returned into Active
    # Remote objects.
    #
    def serialize_records
      return nil unless last_response.respond_to?(:records)

      last_response.records.map do |record|
        remote = self.class.new(record.to_hash)
        remote
      end
    end
  end
end
