require 'active_model/callbacks'

require 'active_remote/association'
require 'active_remote/attribute_definition'
require 'active_remote/attributes'
require 'active_remote/config'
require 'active_remote/dirty'
require 'active_remote/dsl'
require 'active_remote/integration'
require 'active_remote/persistence'
require 'active_remote/primary_key'
require 'active_remote/query_attributes'
require 'active_remote/rpc'
require 'active_remote/scope_keys'
require 'active_remote/search'
require 'active_remote/serialization'
require 'active_remote/validations'

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks

    include ::ActiveModel::Model

    include ::ActiveRemote::Association
    include ::ActiveRemote::Attributes
    include ::ActiveRemote::DSL
    include ::ActiveRemote::Integration
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::PrimaryKey
    include ::ActiveRemote::QueryAttributes
    include ::ActiveRemote::RPC
    include ::ActiveRemote::ScopeKeys
    include ::ActiveRemote::Search
    include ::ActiveRemote::Serialization

    # Overrides some methods, providing support for dirty tracking,
    # so it needs to be included last.
    include ::ActiveRemote::Dirty

    # Overrides persistence methods, so it must included after
    include ::ActiveRemote::Validations
    include ::ActiveModel::Validations::Callbacks

    define_model_callbacks :initialize, :only => :after

    def initialize(attributes = {})
      @attributes = self.class.send(:default_attributes_hash).dup

      assign_attributes(attributes) if attributes

      @new_record = true

      skip_dirty_tracking do
        run_callbacks :initialize do
          yield self if block_given?
        end
      end
    end

    # Initialize an object with the attributes hash directly
    # When used with allocate, bypasses initialize
    def init_with(attributes)
      @attributes = attributes
      @new_record = false

      run_callbacks :initialize

      self
    end

    def freeze
      @attributes.freeze; self
    end

    def frozen?
      @attributes.frozen?
    end
  end

  ActiveSupport.run_load_hooks(:active_remote, Base)
end
