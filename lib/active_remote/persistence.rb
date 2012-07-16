module ActiveRemote
  module Persistence

    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Persistence::ClassMethods
        include ActiveRemote::Persistence::InstanceMethods
      end

      class << klass
        alias_method :create, :save
        alias_method :create!, :save!
      end
    end

    ##
    # Class methods
    #
    module ClassMethods

      def search(args, options = {})
        remote = self.new
        remote._active_remote_search(args)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      def search!(args, options = {})
        remote = search(args, options)
        raise remote.last_response.message if remote.has_errors?
      end

      def save(attributes)
        remote = self.new(attributes)
        remote.save
        remote
      end

      def save!(attributes)
        remote = save(attributes)
        raise remote.last_response.message if remote.has_errors?
      end


      ##
      # Bulk class methods
      #
      def create_all(*records)
        options = records.extract_options!
        remote = self.new
        remote._execute(:create_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      # TODO make bangable
      def create_all!(*records)
        remote = create_all(records)
        raise remote.last_response.message if remote.has_errors?
      end

      def delete_all(*records)
        options = records.extract_options!
        remote = self.new
        remote._execute(:delete_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      # TODO make bangable
      def delete_all!(request, options = {})
        remote = self.new
        remote._execute!(:delete_all, request)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      def destroy_all(*records)
        options = records.extract_options!
        remote = self.new
        remote._execute(:destroy_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      # TODO make bangable
      def destroy_all!(request, options = {})
        remote = self.new
        remote._execute!(:destroy_all, request)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      # Return a protobuf request object for the given rpc request.
      def request(rpc_method, args, options = {})
        bulk = options.fetch(:bulk, false)
        record_or_records = bulk ? records_hash(rpc_method, args) : args
        message_class = request_type(rpc_method)
        build_message(message_class, record_or_records)
      end

      def update_all(*records)
        options = records.extract_options!
        remote = self.new
        remote._execute(:update_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      # TODO make bangable
      def update_all!(request, options = {})
        remote = self.new
        remote._execute!(:update_all, request)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end


      private

      # Make a hash for bulk calls.
      # { :records => [ ..., ... ] }
      def records_hash(rpc_method, records)
        message = request_type(rpc_method).new
        field = message.fields.values.first.name
        { field => records.flatten.compact.uniq }
      end

      # Return the class applicable to the request for the given rpc method.
      def request_type(rpc_method)
        service_class.rpcs[_service][rpc_method].request_type
      end

    end


    ##
    # Instance methods
    #
    module InstanceMethods

      # Search for the given resource.
      def _active_remote_search(args)
        run_callbacks :search do
          _execute(:search, args)
        end
      end

      # Search and return results, raising an error if it failed.
      def _active_remote_search!(args)
        _active_remote_search(args)
        raise @last_response.message if has_errors?
      end

      # Merge the given hash with the existing resource attributes hash.
      def assign_attributes(attributes)
        self.attributes.merge!(attributes)
      end

      # Execute a delete rpc call.
      def delete
        _execute(:delete, attributes)
      end

      # Execute a delete rpc call, raising returned errors.
      def delete!
        _execute(:delete, attributes)
        raise @last_response.message if has_errors?
      end

      # Execute a destroy rpc call.
      def destroy
        _execute(:destroy, attributes)
      end

      # Execute a destroy rpc call, raising returned errors.
      def destroy!
        _execute(:destroy, attributes)
        raise @last_response.message if has_errors?
      end

      # Invoke an RPC call to the service for the given rpc method.
      # Returns a boolean indicating success or failure.
      def _execute(rpc_method, proto, options = {})
        proto = request(rpc_method, proto, options) if proto.is_a?(Hash)
        @last_request = proto

        _service_class.client.__send__(rpc_method, @last_request) do |c|

          # In the event of service failure, record the error.
          c.on_failure do |error|
            errors << error.message
            @last_response = error
          end

          # In the event of service success, assign the response, rewrite the
          # @attributes hash, and mixin AR behavior to the response proto.
          c.on_success do |response|
            @last_response = response

            # TODO: this should be consolidated so its not repeated in the constructor
            @attributes = HashWithIndifferentAccess.new(response.to_hash)
            mimic_response(response)
          end
        end

        return success?
      end

      def has_errors?
        return errors.length > 0
      end

      def new_record?
        return ! persisted?
      end

      def persisted?
        return (attributes.fetch(:id, false) || attributes.fetch(:guid, false))
      end

      def records
        raise @last_response.message if has_errors?
        last_response.records
      end

      def records_hash(rpc_method, records)
        self.class.records_hash(rpc_method, records)
      end

      # Return a protobuf request object for the given rpc call.
      def request(rpc_method, args, options = {})
        self.class.request(rpc_method, args, options)
      end

      # With callbacks, run an update/create call.
      def save
        run_callbacks :save do
          if persisted?
            _execute(:update, attributes)
          else
            _execute(:create, attributes)
          end

          success?
        end
      end

      # Save the given resource to the remote, raising the error
      # if the remote encounters one.
      def save!
        save
        raise @last_response.message if has_errors?
      end

      def success?
        return ! has_errors?
      end

      # Update the given attributres and invoke a save.
      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end

      # Update the given attributres and invoke a save!.
      def update_attributes!(attributes)
        assign_attributes(attributes)
        save!
      end

    end

  end
end
