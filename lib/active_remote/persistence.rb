require 'active_remote/rpc'

module ActiveRemote
  module Persistence
    extend ActiveSupport::Concern

    included do
      include RPC

      # Allow users to create callbacks around a `save` call.
      #
      define_model_callbacks :save, :create, :update

      # Before a save occurs, ensure that we
      # clear out the errors list.
      #
      set_callback :save, :before do |remote|
        remote.errors.clear
      end
    end

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

      # Instantiate a record with the given remote attributes. Generally used
      # when retrieving records that already exist, so @new_record is set to false.
      #
      def instantiate(attributes, options = {})
        new_object = self.new.instantiate(attributes)
        new_object.readonly! if options[:readonly]

        new_object
      end

      # Mark the class as readonly. Overrides instance-level readonly, making
      # any instance of this class readonly.
      def readonly!
        @readonly = true
      end

      # Returns true if the class is marked as readonly; otherwise, returns false.
      def readonly?
        @readonly
      end
    end

    # Deletes the record from the service (the service determines if the
    # record is hard or soft deleted) and freezes this instance to indicate
    # that no changes should be made (since they can't be persisted). If the
    # record was not deleted, it will have error messages indicating what went
    # wrong. Returns the frozen instance.
    #
    def delete
      raise ReadOnlyRemoteRecord if readonly?
      response = rpc.execute(:delete, scope_key_hash)

      add_errors_from_response(response)

      return success? ? freeze : false
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
      raise ReadOnlyRemoteRecord if readonly?
      response = rpc.execute(:destroy, scope_key_hash)

      add_errors_from_response(response)

      return success? ? freeze : false
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

    # Instantiate a record with the given remote attributes. Generally used
    # when retrieving records that already exist, so @new_record is set to false.
    #
    def instantiate(record)
      skip_dirty_tracking do
        assign_attributes(record)
      end

      # TODO: figure out how to safely run after_find/search callbacks here
      # currently, several functions use this code path, so an alternate path
      # may need to be added

      run_callbacks :initialize

      @new_record = false
      self
    end

    # Returns true if the remote record hasn't been saved yet; otherwise,
    # returns false.
    #
    def new_record?
      @new_record
    end

    # Returns true if the remote record has been saved; otherwise, returns false.
    #
    def persisted?
      return ! new_record?
    end

    # Sets the instance to be a readonly object
    #
    def readonly!
      @readonly = true
    end

    # Returns true if the remote class or remote record is readonly; otherwise, returns false.
    def readonly?
      self.class.readonly? || @readonly
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
        create_or_update
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
      save || raise(RemoteRecordNotSaved)
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

  private

    # Handles creating a remote object and serializing it's attributes and
    # errors from the response.
    #
    def create
      run_callbacks :create do
        # Use the getter here so we get the type casting.
        new_attributes = attributes
        new_attributes.delete(primary_key.to_s)

        response = rpc.execute(:create, new_attributes)

        assign_attributes(response.to_hash)
        add_errors_from_response(response)

        @new_record = has_errors?
        success?
      end
    end

    # Deterines whether the record should be created or updated. New records
    # are created, existing records are updated. If the record is marked as
    # readonly, an ActiveRemote::ReadOnlyRemoteRecord is raised.
    #
    def create_or_update
      raise ReadOnlyRemoteRecord if readonly?
      new_record? ? create : update
    end

    # Handles updating a remote object and serializing it's attributes and
    # errors from the response. Only attributes with the given attribute names
    # (plus :guid) will be updated. Defaults to all attributes.
    #
    def update(attribute_names = @attributes.keys)
      run_callbacks :update do
        # Use the getter here so we get the type casting.
        updated_attributes = attributes
        updated_attributes.slice!(*attribute_names)
        updated_attributes.merge!(scope_key_hash)

        response = rpc.execute(:update, updated_attributes)

        assign_attributes(response.to_hash)
        add_errors_from_response(response)

        success?
      end
    end
  end
end
