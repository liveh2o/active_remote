require "active_remote/rpc"

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
      def instantiate(new_attributes, options = {})
        attributes = self.build_from_rpc(new_attributes)
        new_object = self.allocate.init_with(attributes)
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

      response = remote_call(:delete, scope_key_hash)

      add_errors(response.errors) if response.respond_to?(:errors)

      success? ? freeze : false
    end

    # Deletes the record from the service (the service determines if the
    # record is hard or soft deleted) and freezes this instance to indicate
    # that no changes should be made (since they can't be persisted). If the
    # record was not deleted, an exception will be raised. Returns the frozen
    # instance.
    #
    def delete!
      delete
      raise ActiveRemoteError, errors.to_s if has_errors?
    end

    # Destroys (hard deletes) the record from the service and freezes this
    # instance to indicate that no changes should be made (since they can't
    # be persisted). If the record was not deleted, it will have error
    # messages indicating what went wrong. Returns the frozen instance.
    #
    def destroy
      raise ReadOnlyRemoteRecord if readonly?

      response = remote_call(:destroy, scope_key_hash)

      add_errors(response.errors) if response.respond_to?(:errors)

      success? ? freeze : false
    end

    # Destroys (hard deletes) the record from the service and freezes this
    # instance to indicate that no changes should be made (since they can't
    # be persisted). If the record was not deleted, an exception will be
    # raised. Returns the frozen instance.
    #
    def destroy!
      destroy
      raise ActiveRemoteError, errors.to_s if has_errors?
    end

    # Returns true if the record has errors; otherwise, returns false.
    #
    def has_errors?
      respond_to?(:errors) && errors.present?
    end

    # Instantiate a record with the given remote attributes. Generally used
    # when retrieving records that already exist, so @new_record is set to false.
    #
    def instantiate(new_attributes)
      new_attributes = self.class.build_from_rpc(new_attributes)
      init_with(new_attributes)
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
      !new_record?
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

    # Executes a remote call on the current object and serializes it's attributes and
    # errors from the response.
    #
    # Defaults request args to the scope key hash (e.g., { guid: 'ABC-123' }) when none are given.
    # Returns false if the response contained errors; otherwise, returns true.
    #
    def remote(endpoint, request_args = scope_key_hash)
      response = remote_call(endpoint, request_args)
      assign_attributes_from_rpc(response)

      success?
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
    def save(*args)
      run_callbacks :save do
        create_or_update(*args)
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
    def save!(*args)
      save(*args) || fail(RemoteRecordNotSaved, self)
    end

    # Returns true if the record doesn't have errors; otherwise, returns false.
    #
    def success?
      !has_errors?
    end

    # Updates a single attribute and saves the record.
    # This is especially useful for boolean flags on existing records. Also note that
    #
    # * Validation is skipped.
    # * Callbacks are invoked.
    # * Updates all the attributes that are dirty in this object.
    #
    # This method raises an ActiveRemote::ReadOnlyRemoteRecord  if the
    # attribute is marked as readonly.
    def update_attribute(name, value)
      raise ReadOnlyRemoteRecord if readonly?

      name = name.to_s
      send("#{name}=", value)
      save(:validate => false)
    end

    # Updates the attributes of the remote record from the passed-in hash and
    # saves the remote record. If the object is invalid, it will have error
    # messages and false will be returned.
    #
    def update_attributes(attributes)
      assign_attributes(attributes)
      save
    end
    alias_method :update, :update_attributes

    # Updates the attributes of the remote record from the passed-in hash and
    # saves the remote record. If the object is invalid, an
    # ActiveRemote::RemoteRecordNotSaved is raised.
    #
    def update_attributes!(attributes)
      assign_attributes(attributes)
      save!
    end
    alias_method :update!, :update_attributes!

  private

    # Handles creating a remote object and serializing it's attributes and
    # errors from the response.
    #
    def remote_create
      run_callbacks :create do
        remote(:create, attributes)

        @new_record = has_errors?
        success?
      end
    end

    # Deterines whether the record should be created or updated. New records
    # are created, existing records are updated. If the record is marked as
    # readonly, an ActiveRemote::ReadOnlyRemoteRecord is raised.
    #
    def create_or_update(*args)
      raise ReadOnlyRemoteRecord if readonly?

      new_record? ? remote_create : remote_update(*args)
    end

    # Handles updating a remote object and serializing it's attributes and
    # errors from the response. Only attributes with the given attribute names
    # (plus :guid) will be updated. Defaults to all attributes.
    #
    def remote_update(attribute_names = @attributes.keys)
      run_callbacks :update do
        # Use the getter here so we get the type casting.
        updated_attributes = attributes
        updated_attributes.slice!(*attribute_names)
        updated_attributes.merge!(scope_key_hash)

        remote(:update, updated_attributes)
      end
    end
  end
end
