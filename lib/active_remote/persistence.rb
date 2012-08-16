require 'active_remote/rpc'

module ActiveRemote
  module Persistence
    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Persistence::ClassMethods
        include ActiveRemote::Persistence::InstanceMethods
        include ActiveRemote::RPC unless include?(ActiveRemote::RPC)
      end
    end

    ##
    # Class methods
    #
    module ClassMethods
      def create(attributes)
        remote = self.new(attributes)
        remote.save
        remote
      end

      def create!(attributes)
        remote = self.new(attributes)
        remote.save!
        remote
      end

      ##
      # Bulk class methods
      #
      def create_all(*records)
        remote = self.new
        remote._execute(:create_all, { :records => records.flatten })
        remote.serialize_records
      end

      def create_all!(*records)
        remote_records = create_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      def delete_all(*records)
        remote = self.new
        remote._execute(:delete_all, { :records => records.flatten })
        remote.serialize_records
      end

      def delete_all!(*records)
        remote_records = delete_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      def destroy_all(*records)
        remote = self.new
        remote._execute(:destroy_all, { :records => records.flatten })
        remote.serialize_records
      end

      def destroy_all!(*records)
        remote_records = destroy_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      def update_all(*records)
        remote = self.new
        remote._execute(:update_all, { :records => records.flatten })
        remote.serialize_records
      end

      def update_all!(*records)
        remote_records = update_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end
    end

    ##
    # Instance methods
    #
    module InstanceMethods

      # Merge the given hash with the existing resource attributes hash.
      #
      def assign_attributes(attributes)
        self.attributes.merge!(attributes)
      end

      # Execute a delete rpc call.
      #
      def delete
        _execute(:delete, attributes)
      end

      # Execute a delete rpc call, raising returned errors.
      #
      def delete!
        delete
        raise ActiveRemoteError.new(errors.to_s) if has_errors?
      end

      # Execute a destroy rpc call.
      #
      def destroy
        _execute(:destroy, attributes)
      end

      # Execute a destroy rpc call, raising returned errors.
      #
      def destroy!
        destroy
        raise ActiveRemoteError.new(errors.to_s) if has_errors?
      end

      # Checks to see if the remote object has errors.
      #
      def has_errors?
        return respond_to?(:errors) && errors.present?
      end

      def new_record?
        return ! persisted?
      end

      def persisted?
        return (attributes.fetch(:id, false) || attributes.fetch(:guid, false))
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
        raise RemoteRecordNotSaved.new(errors.to_s) if has_errors?
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
