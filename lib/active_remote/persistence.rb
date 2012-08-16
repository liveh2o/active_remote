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
        include ActiveRemote::RPC unless include?(ActiveRemote::RPC)
      end
    end

    ##
    # Class methods
    #
    module ClassMethods
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
    end


    ##
    # Instance methods
    #
    module InstanceMethods

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
