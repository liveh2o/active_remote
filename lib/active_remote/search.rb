require "active_remote/persistence"
require "active_remote/rpc"

module ActiveRemote
  module Search
    extend ActiveSupport::Concern

    included do
      include Persistence
      include RPC
    end

    module ClassMethods
      # Tries to load the first record; if it fails, an exception is raised.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.find(:guid => 'foo')
      #
      #   # Active remote object
      #   Tag.find(Tag.new(:guid => 'foo'))
      #
      #   # Protobuf object
      #   Tag.find(Generic::Remote::TagRequest.new(:guid => ['foo']))
      #
      def find(args)
        remote = search(args).first
        raise RemoteRecordNotFound, self if remote.nil?

        remote
      end

      # Tries to load the first record; if it fails, returns nil.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.find_by(:guid => 'foo')
      #
      #   # Active remote object
      #   Tag.find_by(Tag.new(:guid => 'foo'))
      #
      #   # Protobuf object
      #   Tag.find_by(Generic::Remote::TagRequest.new(:guid => ['foo']))
      #
      def find_by(args)
        search(args).first
      end

      # Tries to load the first record; if it fails, then create is called with
      # the same arguments, with any repeated search field unwrapped to a single
      # value. Raises ArgumentError if a field carries more than one value.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.first_or_create(:name => 'foo')
      #
      #   # Protobuf object
      #   Tag.first_or_create(Generic::Remote::TagRequest.new(:name => ['foo']))
      #
      def first_or_create(attributes)
        attributes = validate_search_args!(attributes)
        search(attributes).first || create(attributes_for_record(attributes))
      end

      # Tries to load the first record; if it fails, then create! is called
      # with the same arguments. Unwraps repeated search fields as
      # .first_or_create does.
      #
      def first_or_create!(attributes)
        attributes = validate_search_args!(attributes)
        search(attributes).first || create!(attributes_for_record(attributes))
      end

      # Tries to load the first record; if it fails, then a new record is
      # initialized with the same arguments. Unwraps repeated search fields as
      # .first_or_create does.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.first_or_initialize(:name => 'foo')
      #
      #   # Protobuf object
      #   Tag.first_or_initialize(Generic::Remote::TagRequest.new(:name => ['foo']))
      #
      def first_or_initialize(attributes)
        attributes = validate_search_args!(attributes)
        search(attributes).first || new(attributes_for_record(attributes))
      end

      # Searches for records with the given arguments. Returns a collection of
      # Active Remote objects.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.search(:name => 'foo')
      #
      #   # Protobuf object
      #   Tag.search(Generic::Remote::TagRequest.new(:name => ['foo']))
      #
      def search(args)
        args = validate_search_args!(args)

        response = remote_call(:search, args)

        if response.respond_to?(:records)
          serialize_records(response.records)
        else
          response
        end
      end

      # Validates the given args to ensure they are compatible. Search args must
      # be a Hash, an ActiveRemote::Base, or respond to :to_hash.
      #
      def validate_search_args!(args)
        return args if args.is_a?(Hash)
        return args.attributes if args.is_a?(::ActiveRemote::Base)
        return args.to_hash if args.respond_to?(:to_hash)

        raise "Invalid parameter: #{args}. Search args must respond to :to_hash."
      end

      private

      # Search fields are repeated so callers can match many records at once,
      # but the record's attribute is scalar: ["foo"] would cast to "[\"foo\"]".
      #
      def attributes_for_record(args)
        args.to_h do |name, value|
          next [name, value] unless value.is_a?(::Array)

          # A type that takes the array unchanged is meant to hold it.
          next [name, value] if attribute_types[name.to_s].cast(value) == value

          if value.size > 1
            raise ArgumentError, "Cannot build #{self} from #{name.inspect} => #{value.inspect}. " \
              "#{name} holds a single value, but #{value.size} were given."
          end

          [name, value.first]
        end
      end
    end

    # Reload this record from the remote service.
    #
    def reload
      fresh_object = self.class.find(scope_key_hash)
      @attributes = fresh_object.instance_variable_get(:@attributes)
      @new_record = false
      self
    end
  end
end
