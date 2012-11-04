require 'active_remote/persistence'
require 'active_remote/rpc'

module ActiveRemote
  module Search
    def self.included(klass)
      klass.class_eval do
        extend ::ActiveRemote::Search::ClassMethods
        include ::ActiveRemote::Persistence
        include ::ActiveRemote::RPC

        define_model_callbacks :search
      end
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
        raise RemoteRecordNotFound if remote.nil?

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
        args = _active_remote_search_args(args)

        remote = self.new
        remote._active_remote_search(args)
        remote.serialize_records
      end

      # :noapi:
      def _active_remote_search_args(args)
        unless args.is_a?(Hash)
          if args.respond_to?(:to_hash)
            args = args.to_hash
          else
            raise "Invalid parameter: #{args}. First parameter must respond to :to_hash."
          end
        end

        args
      end
    end

    # Search for the given resource. Auto-paginates (i.e. continues searching
    # for records matching the given search args until all records have been
    # retrieved) if no pagination options are given.
    #
    def _active_remote_search(args)
      run_callbacks :search do
        execute(:search, args)
      end
    end

    # Reload this record from the remote service.
    #
    def reload
      _active_remote_search(:guid => self.guid)
      assign_attributes(last_response.to_hash)
    end
  end
end
