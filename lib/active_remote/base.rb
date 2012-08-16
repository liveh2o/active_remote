require 'active_remote/dsl'
require 'active_remote/rpc'
require 'active_remote/persistence'
require 'active_remote/serialization'

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks
    include ::ActiveModel::Serializers::JSON

    include ::ActiveRemote::DSL
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::RPC
    include ::ActiveRemote::Serialization

    attr_reader :attributes, :errors, :last_request, :last_response

    define_model_callbacks :initialize, :only => :after
    define_model_callbacks :search, :only => :after
    define_model_callbacks :save

    def initialize(attributes = {})
      run_callbacks :initialize do
        @attributes = HashWithIndifferentAccess.new(attributes.to_hash)
        @errors = []
      end
    end

  end
end
