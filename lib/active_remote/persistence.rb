require 'active_remote/rpc'

module ActiveRemote
  module Persistence
    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Persistence::ClassMethods
        include ActiveRemote::Persistence::InstanceMethods
        include ActiveRemote::RPC
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
    end

    ##
    # Instance methods
    #
    module InstanceMethods

      # Allows you to set all of the remote record's attributes by passing in
      # a hash of attributes with keys matching attribute names.
      #
      # def assign_attributes(attributes)
      #   self.attributes.merge!(attributes)
      #
      #   self.attributes.each do |key, value|
      #     setter = "#{key}="
      #     __send__(setter, value) if respond_to?(setter)
      #   end
      # end

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
        return self[:guid].nil?
      end

      # Returns true if the remote record has been saved; otherwise, returns false.
      #
      def persisted?
        return ! new_record?
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

      def create
        _execute(:create, attributes)
        assign_attributes(last_response.to_hash)
        add_errors_from_response
        success?
      end

      def create_or_update
        new_record? ? create : update
      end

      def update
        _execute(:update, attributes)
        assign_attributes(last_response.to_hash)
        add_errors_from_response
        success?
      end
    end
  end
end
