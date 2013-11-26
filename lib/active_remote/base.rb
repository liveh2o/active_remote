require 'active_remote/association'
require 'active_remote/attributes'
require 'active_remote/bulk'
require 'active_remote/config'
require 'active_remote/dirty'
require 'active_remote/dsl'
require 'active_remote/integration'
require 'active_remote/persistence'
require 'active_remote/publication'
require 'active_remote/rpc'
require 'active_remote/search'
require 'active_remote/serialization'

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks

    include ::ActiveAttr::Model

    include ::ActiveRemote::Association
    include ::ActiveRemote::Attributes
    include ::ActiveRemote::Bulk
    include ::ActiveRemote::DSL
    include ::ActiveRemote::Integration
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::Publication
    include ::ActiveRemote::RPC
    include ::ActiveRemote::Search
    include ::ActiveRemote::Serialization

    # Overrides some methods, providing support for dirty tracking,
    # so it needs to be included last.
    include ::ActiveRemote::Dirty

    attr_reader :last_request, :last_response

    define_model_callbacks :initialize, :only => :after

    def initialize(*)
      @attributes ||= {}
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

  ::ActiveSupport.run_load_hooks(:active_remote, Base)
end
