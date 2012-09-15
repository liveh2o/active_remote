require 'active_remote/bulk'
require 'active_remote/dsl'
require 'active_remote/persistence'
require 'active_remote/rpc'
require 'active_remote/search'
require 'active_remote/serialization'

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks

    include ::ActiveAttr::Model

    include ::ActiveRemote::Bulk
    include ::ActiveRemote::DSL
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::RPC
    include ::ActiveRemote::Search
    include ::ActiveRemote::Serialization

    attr_reader :last_request, :last_response

    define_model_callbacks :initialize, :only => :after
    define_model_callbacks :search, :only => :after
    define_model_callbacks :save

    def initialize(*)
      run_callbacks :initialize do
        super
      end
    end

    def freeze
      @attributes.freeze; self
    end

    def frozen?
      @attributes.frozen?
    end
  end
end
