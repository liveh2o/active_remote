module ActiveRemote
  module Serialization
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Serializers::JSON
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
  end
end
