require 'active_remote/serializers/json'

module ActiveRemote
  module Serialization
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Serializers::JSON
      include Serializers::JSON
    end

    module ClassMethods
      # Serialize the given records into Active Remote objects.
      #
      # ====Examples
      #
      #   records = [ Generic::Remote::TagRequest.new(:name => 'foo') ]
      #
      #   Tag.serialize_records(records) # => [ Tag#{:name => 'foo'} ]
      #
      def serialize_records(records)
        records.map do |record|
          model = instantiate(record.to_hash)
          model.add_errors(record.errors) if record.respond_to?(:errors)
          model
        end
      end
    end

    # Add the given errors to our internal errors list
    #
    # ====Examples
    #
    #   response = remote_call(:action_that_returns_errors, { :stuff => 'foo' })
    #
    #   add_errors(response.errors)
    #
    def add_errors(errors)
      errors.each do |error|
        if error.respond_to?(:message)
          self.errors.add(error.field, error.message)
        elsif error.respond_to?(:messages)
          error.messages.each do |message|
            self.errors.add(error.field, message)
          end
        end
      end
    end

    # Examine the given response and add any errors to our internal errors
    # list.
    #
    # ====Examples
    #
    #   response = remote_call(:action_that_returns_errors, { :stuff => 'foo' })
    #
    #   add_errors_from_response(response)
    #
    def add_errors_from_response(response = nil)
      unless response
        warn 'DEPRECATED calling Model#add_errors_from_response without args is deprecated and will be removed in Active Remote 3.0.'
        response = last_response
      end

      add_errors(response.errors) if response.respond_to?(:errors)
    end

    # DEPRECATED – Use the class-level :serialize_errors instead
    #
    def serialize_records(records = nil)
      warn 'DEPRECATED Calling Model#serialize_records is deprecated and will be removed in Active Remote 3.0. Use Model.serialize_records instead'

      records ||= last_response.records if last_response.respond_to?(:records)
      return if records.nil?

      self.class.serialize_records(records)
    end
  end
end
