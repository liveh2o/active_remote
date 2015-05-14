module ActiveRemote
  module Validations
    extend ActiveSupport::Concern

    # Attempts to save the record like Persistence, but will run
    # validations and return false if the record is invalid
    #
    # Validations can be skipped by passing :validate => false
    #
    # example Save a record
    #   post.save
    #
    # example Save a record, skip validations
    #  post.save(:validate => false)
    #
    def save(options = {})
      perform_validations(options) ? super : false
    end

    # Attempts to save the record like Persistence, but will raise
    # ActiveRemote::RemoteRecordInvalid if the record is not valid
    #
    # Validations can be skipped by passing :validate => false
    #
    # example Save a record, raise and error if invalid
    #   post.save!
    #
    # example Save a record, skip validations
    #  post.save!(:validate => false)
    #
    def save!(options = {})
      perform_validations(options) ? super : raise_validation_error
    end

    # Runs all the validations within the specified context. Returns true if
    # no errors are found, false otherwise.
    #
    # Aliased as validate.
    #
    # example Is the record valid?
    #   post.valid?
    #
    # example Is the record valid for creation?
    #   post.valid?(:create)
    #
    def valid?(context = nil)
      context ||= (new_record? ? :create : :update)
      output = super(context)
      errors.empty? && output
    end

    alias_method :validate, :valid?

  protected

    def raise_validation_error
      fail(::ActiveRemote::RemoteRecordInvalid.new(self))
    end

    def perform_validations(options = {})
      options[:validate] == false || valid?(options[:context])
    end
  end
end
