require 'active_model/callbacks'

require 'active_remote/association'
require 'active_remote/attribute_defaults'
require 'active_remote/attribute_definition'
require 'active_remote/attributes'
require 'active_remote/bulk'
require 'active_remote/block_initialization'
require 'active_remote/config'
require 'active_remote/chainable_initialization'
require 'active_remote/dirty'
require 'active_remote/dsl'
require 'active_remote/integration'
require 'active_remote/mass_assignment'
require 'active_remote/persistence'
require 'active_remote/primary_key'
require 'active_remote/rpc'
require 'active_remote/scope_keys'
require 'active_remote/search'
require 'active_remote/serialization'
require 'active_remote/typecasting'
require 'active_remote/validations'

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks
    extend ::ActiveModel::Naming

    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    include ::ActiveRemote::Association
    include ::ActiveRemote::AttributeDefaults
    include ::ActiveRemote::Attributes
    include ::ActiveRemote::Bulk
    include ::ActiveRemote::BlockInitialization
    include ::ActiveRemote::ChainableInitialization
    include ::ActiveRemote::DSL
    include ::ActiveRemote::Integration
    include ::ActiveRemote::MassAssignment
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::PrimaryKey
    include ::ActiveRemote::RPC
    include ::ActiveRemote::ScopeKeys
    include ::ActiveRemote::Search
    include ::ActiveRemote::Serialization
    include ::ActiveRemote::Typecasting

    # Overrides some methods, providing support for dirty tracking,
    # so it needs to be included last.
    include ::ActiveRemote::Dirty

    # Overrides persistence methods, so it must included after
    include ::ActiveRemote::Validations
    include ::ActiveModel::Validations::Callbacks

    attr_reader :last_request, :last_response

    define_model_callbacks :initialize, :only => :after

    def initialize(*)
      @attributes ||= begin
        attribute_names = self.class.attribute_names
        Hash[attribute_names.map { |key| [key, send(key)] }]
      end

      @new_record = true

      skip_dirty_tracking do
        run_callbacks :initialize do
          super
        end
      end
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
