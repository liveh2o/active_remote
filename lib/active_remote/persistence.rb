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

      # Creates a remote record through the service.
      #
      # The service will run any validations and if any of them fail, will return
      # the record error messages indicating what went wrong.
      #
      # The newly created record is returned if it was successfully saved or not.
      #
      def create(attributes)
        remote = self.new(attributes)
        remote.save
        remote
      end

      # Creates a remote record through the service and if successful, returns
      # the newly created record.
      #
      # The service will run any validations and if any of them fail, will raise
      # an ActiveRemote::RemoteRecordNotSaved exception.
      #
      def create!(attributes)
        remote = self.new(attributes)
        remote.save!
        remote
      end

      # Create multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. Records that were not created
      # are returned with error messages indicating what went wrong.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.create_all({ :name => 'foo' })
      #
      #   # Hashes
      #   Tag.create_all({ :name => 'foo' }, { :name => 'bar' })
      #
      #   # Active remote objects
      #   Tag.create_all(Tag.new(:name => 'foo'), Tag.new(:name => 'bar'))
      #
      #   # Protobuf objects
      #   Tag.create_all(Atlas::Abacus::Tag.new(:name => 'foo'), Atlas::Abacus::Tag.new(:name => 'bar'))
      #
      #   # Bulk protobuf object
      #   Tag.create_all(Atlas::Abacus::Tags.new(:records => [ Atlas::Abacus::Tag.new(:name => 'foo') ])
      #
      def create_all(*records)
        remote = self.new
        remote._execute(:create_all, parse_records(records))
        remote.serialize_records
      end

      # Create multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. If the service returns any record
      # with error messages, raises an ActiveRemote::RemoteRecordNotSaved exception.
      #
      def create_all!(*records)
        remote_records = create_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      # Delete multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. Records that were not deleted
      # are returned with error messages indicating what went wrong.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.delete_all({ :guid => 'foo' })
      #
      #   # Hashes
      #   Tag.delete_all({ :guid => 'foo' }, { :guid => 'bar' })
      #
      #   # Active remote objects
      #   Tag.delete_all(Tag.new(:guid => 'foo'), Tag.new(:guid => 'bar'))
      #
      #   # Protobuf objects
      #   Tag.delete_all(Atlas::Abacus::Tag.new(:guid => 'foo'), Atlas::Abacus::Tag.new(:guid => 'bar'))
      #
      #   # Bulk protobuf object
      #   Tag.delete_all(Atlas::Abacus::Tags.new(:records => [ Atlas::Abacus::Tag.new(:guid => 'foo') ])
      #
      def delete_all(*records)
        remote = self.new
        remote._execute(:delete_all, parse_records(records))
        remote.serialize_records
      end

      # Delete multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. If the service returns any record
      # with error messages, raises an ActiveRemote::RemoteRecordNotSaved exception.
      #
      def delete_all!(*records)
        remote_records = delete_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      # Destroy multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. Records that were not destroyed
      # are returned with error messages indicating what went wrong.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.destroy_all({ :guid => 'foo' })
      #
      #   # Hashes
      #   Tag.destroy_all({ :guid => 'foo' }, { :guid => 'bar' })
      #
      #   # Active remote objects
      #   Tag.destroy_all(Tag.new(:guid => 'foo'), Tag.new(:guid => 'bar'))
      #
      #   # Protobuf objects
      #   Tag.destroy_all(Atlas::Abacus::Tag.new(:guid => 'foo'), Atlas::Abacus::Tag.new(:guid => 'bar'))
      #
      #   # Bulk protobuf object
      #   Tag.destroy_all(Atlas::Abacus::Tags.new(:records => [ Atlas::Abacus::Tag.new(:guid => 'foo') ])
      #
      def destroy_all(*records)
        remote = self.new
        remote._execute(:destroy_all, parse_records(records))
        remote.serialize_records
      end

      # Destroy multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. If the service returns any record
      # with error messages, raises an ActiveRemote::RemoteRecordNotSaved exception.
      #
      def destroy_all!(*records)
        remote_records = destroy_all(records)

        raise RemoteRecordNotSaved if remote_records.detect { |remote| remote.has_errors? }
        remote_records
      end

      # Parse given records to get them ready to be built into a request.
      #
      # It handles any object that responds to +to_hash+, so protobuf messages
      # and active remote objects will work just like hashes.
      #
      # Returns +{ :records => records }+.
      #
      def parse_records(*records)
        records.flatten!
        records.collect!(&:to_hash)

        return records.first if records.first.has_key?(:records)

        # If we made it this far, build a bulk-formatted hash.
        return { :records => records }
      end

      # Update multiple records at the same time. Returns a collection of active
      # remote objects from the passed records. Records that were not updated
      # are returned with error messages indicating what went wrong.
      #
      # ====Examples
      #
      #   # A single hash
      #   Tag.update_all({ :guid => 'foo', :name => 'baz' })
      #
      #   # Hashes
      #   Tag.update_all({ :guid => 'foo', :name => 'baz' }, { :guid => 'bar', :name => 'qux' })
      #
      #   # Active remote objects
      #   Tag.update_all(Tag.new(:guid => 'foo', :name => 'baz'), Tag.new(:guid => 'bar', :name => 'qux'))
      #
      #   # Protobuf objects
      #   Tag.update_all(Atlas::Abacus::Tag.new(:guid => 'foo', :name => 'baz'), Atlas::Abacus::Tag.new(:guid => 'bar', :name => 'qux'))
      #
      #   # Bulk protobuf object
      #   Tag.update_all(Atlas::Abacus::Tags.new(:records => [ Atlas::Abacus::Tag.new(:guid => 'foo', :name => 'baz') ])
      #
      def update_all(*records)
        remote = self.new
        remote._execute(:update_all, parse_records(records))
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

      # Allows you to set all of the remote record's attributes by passing in
      # a hash of attributes with keys matching attribute names.
      #
      def assign_attributes(attributes)
        self.attributes.merge!(attributes)
      end

      # Deletes the record from the service (the service determines if the
      # record is hard or soft deleted) and freezes this instance to indicate
      # that no changes should be made (since they can't be persisted). If the
      # record was not deleted, it will have error messages indicating what went
      # wrong. Returns the frozen instance.
      #
      def delete
        _execute(:delete, attributes)
        freeze if success?
      end

      # Deletes the record from the service (the service determines if the
      # record is hard or soft deleted) and freezes this instance to indicate
      # that no changes should be made (since they can't be persisted). If the
      # record was not deleted, an exception will be raised. Returns the frozen
      # instance.
      #
      def delete!
        delete
        raise ActiveRemoteError.new(errors.to_s) if has_errors?
      end

      # Destroys (hard deletes) the record from the service and freezes this
      # instance to indicate that no changes should be made (since they can't
      # be persisted). If the record was not deleted, it will have error
      # messages indicating what went wrong. Returns the frozen instance.
      #
      def destroy
        _execute(:destroy, attributes)
        freeze if success?
      end

      # Destroys (hard deletes) the record from the service and freezes this
      # instance to indicate that no changes should be made (since they can't
      # be persisted). If the record was not deleted, an exception will be
      # raised. Returns the frozen instance.
      #
      def destroy!
        destroy
        raise ActiveRemoteError.new(errors.to_s) if has_errors?
      end

      # Returns true if the record has errors; otherwise, returns false.
      #
      def has_errors?
        return respond_to?(:errors) && errors.present?
      end

      # Returns true if the remote record hasn't been saved yet; otherwise,
      # returns false.
      #
      def new_record?
        return ! persisted?
      end

      # Returns true if the remote record has been saved; otherwise, returns false.
      #
      def persisted?
        return attributes.fetch(:guid, false) || false
      end

      # Saves the remote record.
      #
      # If it is a new record, it will be created through the service, otherwise
      # the existing record gets updated.
      #
      # The service will run any validations and if any of them fail, will return
      # the record with error messages indicating what went wrong.
      #
      # Also runs any before/after save callbacks that are defined.
      #
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

      # Saves the remote record.
      #
      # If it is a new record, it will be created through the service, otherwise
      # the existing record gets updated.
      #
      # The service will run any validations. If any of them fail (e.g. error
      # messages are returned), an ActiveRemote::RemoteRecordNotSaved is raised.
      #
      # Also runs any before/after save callbacks that are defined.
      #
      def save!
        save
        raise RemoteRecordNotSaved.new(errors.to_s) if has_errors?
      end

      # Returns true if the record doesn't have errors; otherwise, returns false.
      #
      def success?
        return ! has_errors?
      end

      # Updates the attributes of the remote record from the passed-in hash and
      # saves the remote record. If the object is invalid, it will have error
      # messages and false will be returned.
      #
      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end

      # Updates the attributes of the remote record from the passed-in hash and
      # saves the remote record. If the object is invalid, an
      # ActiveRemote::RemoteRecordNotSaved is raised.
      #
      def update_attributes!(attributes)
        assign_attributes(attributes)
        save!
      end
    end
  end
end
