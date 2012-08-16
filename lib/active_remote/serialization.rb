require 'active_remote/serializers/json'

module ActiveRemote
  module Serialization

    def self.included(klass)
      klass.class_eval do
        include ::ActiveRemote::Serializers::JSON
      end
    end

    # Returns an array of records that have been endowed with
    # ActiveRemote capabilities via #mimic_response.
    #
    def serialize_records
      last_response.records.map do |record|
        remote = self.class.new(record.to_hash)
        remote.__send__(:mimic_response, record)
        remote
      end
    end

  private

    # Endow a proto object with ActiveRemote capabilities.
    #
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
