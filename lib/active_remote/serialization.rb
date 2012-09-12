require 'active_remote/serializers/json'

module ActiveRemote
  module Serialization

    def self.included(klass)
      klass.class_eval do
        include ::ActiveRemote::Serializers::JSON
      end
    end

    def serialize_records
      last_response.records.map do |record|
        remote = self.class.new(record.to_hash)
        remote
      end
    end
  end
end
