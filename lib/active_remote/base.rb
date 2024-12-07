require "active_model/callbacks"

require "active_remote/association"
require "active_remote/attribute_methods"
require "active_remote/config"
require "active_remote/dirty"
require "active_remote/dsl"
require "active_remote/integration"
require "active_remote/persistence"
require "active_remote/primary_key"
require "active_remote/query_attributes"
require "active_remote/rpc"
require "active_remote/scope_keys"
require "active_remote/search"
require "active_remote/serialization"
require "active_remote/validations"

module ActiveRemote
  class Base
    extend ::ActiveModel::Callbacks

    include ::ActiveModel::Model
    include ::ActiveModel::Attributes

    include ::ActiveRemote::Association
    include ::ActiveRemote::AttributeMethods
    include ::ActiveRemote::DSL
    include ::ActiveRemote::Integration
    include ::ActiveRemote::QueryAttributes
    include ::ActiveRemote::Persistence
    include ::ActiveRemote::PrimaryKey

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

    define_model_callbacks :initialize, only: :after

    def initialize(attributes = {})
      super
      @new_record = true

      run_callbacks :initialize do
        yield self if block_given?
      end
    end

    # Returns true if +comparison_object+ is the same exact object, or +comparison_object+
    # is of the same type and +self+ has an ID and it is equal to +comparison_object.id+.
    #
    # Note that new records are different from any other record by definition, unless the
    # other record is the receiver itself. Besides, if you fetch existing records with
    # +select+ and leave the ID out, you're on your own, this predicate will return false.
    #
    # Note also that destroying a record preserves its ID in the model instance, so deleted
    # models are still comparable.
    def ==(other)
      super ||
        other.instance_of?(self.class) &&
          !send(primary_key).nil? &&
          other.send(primary_key) == send(primary_key)
    end
    alias_method :eql?, :==

    # Allows sort on objects
    def <=>(other)
      if other.is_a?(self.class)
        to_key <=> other.to_key
      else
        super
      end
    end

    def freeze
      @attributes.freeze
      self
    end

    def frozen?
      @attributes.frozen?
    end

    # Initialize an object with the attributes hash directly
    # When used with allocate, bypasses initialize
    def init_with(attributes)
      @attributes = attributes
      @new_record = false

      run_callbacks :initialize

      self
    end

    # Returns the contents of the record as a nicely formatted string.
    def inspect
      # We check defined?(@attributes) not to issue warnings if the object is
      # allocated but not initialized.
      inspection = if defined?(@attributes) && @attributes
        attribute_names.collect do |name, _|
          if attribute?(name)
            "#{name}: #{attribute_for_inspect(name)}"
          else
            name
          end
        end.compact.join(", ")
      else
        "not initialized"
      end

      "#<#{self.class} #{inspection}>"
    end

    # Returns a hash of the given methods with their names as keys and returned values as values.
    def slice(*methods)
      methods.flatten.map! { |method| [method, public_send(method)] }.to_h.with_indifferent_access
    end
  end

  ::ActiveModel::Type.register(:value, ::ActiveModel::Type::Value)

  ::ActiveSupport.run_load_hooks(:active_remote, Base)
end
