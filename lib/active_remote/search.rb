require 'active_remote/persistence'
require 'active_remote/rpc'

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
      #   Tag.find(Generic::Remote::TagRequest.new(:guid => 'foo'))
      #
      def find(args)
        remote = self.search(args).first
        raise RemoteRecordNotFound.new(self) if remote.nil?

        return remote
      end

      # Tries to load the first record; if it fails, then create is called
      # with the same arguments.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.first_or_create(:name => 'foo')
      #
      #   # Protobuf object
      #   Tag.first_or_create(Generic::Remote::TagRequest.new(:name => 'foo'))
      #
      def first_or_create(attributes)
        remote = self.search(attributes).first
        remote ||= self.create(attributes)
        remote
      end

      # Tries to load the first record; if it fails, then create! is called
      # with the same arguments.
      #
      def first_or_create!(attributes)
        remote = self.search(attributes).first
        remote ||= self.create!(attributes)
        remote
      end

      # Tries to load the first record; if it fails, then a new record is
      # initialized with the same arguments.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.first_or_initialize(:name => 'foo')
      #
      #   # Protobuf object
      #   Tag.first_or_initialize(Generic::Remote::TagRequest.new(:name => 'foo'))
      #
      def first_or_initialize(attributes)
        remote = self.search(attributes).first
        remote ||= self.new(attributes)
        remote
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
      #   Tag.search(Generic::Remote::TagRequest.new(:name => 'foo'))
      #
      def search(args)
        args = validate_search_args!(args)

        response = rpc.execute(:search, args)

        if response.respond_to?(:records)
          records = serialize_records(response.records)
        end
      end

      # Validates the given args to ensure they are compatible
      # Search args must be a hash or respond to to_hash
      #
      def validate_search_args!(args)
        unless args.is_a?(Hash)
          if args.respond_to?(:to_hash)
            args = args.to_hash
          else
            raise "Invalid parameter: #{args}. Search args must respond to :to_hash."
          end
        end

        args
      end
    end

    # :noapi:
    def _active_remote_search(args)
      warn "DEPRECATED Model#_active_remote_search is depracted and will be remoted in Active Remote 3.0."

      run_callbacks :search do
        rpc.execute(:search, args)
      end
    end

    # Reload this record from the remote service.
    #
    def reload
      fresh_object = self.class.find(scope_key_hash)
      @attributes.update(fresh_object.instance_variable_get('@attributes'))
    end
  end
end
