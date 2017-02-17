# TODO: Create more specific errors
#
module ActiveRemote
  # Generic Active Remote exception class.
  class ActiveRemoteError < StandardError
  end

  # Raised by ActiveRemove::Base.save when the remote record is readonly.
  class ReadOnlyRemoteRecord < ActiveRemoteError
  end

  # Raised by ActiveRemote::Validations when save is called on an invalid record.
  class RemoteRecordInvalid < ActiveRemoteError
    attr_reader :record

    def initialize(record)
      @record = record
      errors = @record.errors.full_messages.join(', ')
      super(errors)
    end
  end

  # Raised by ActiveRemove::Base.find when remote record is not found when
  # searching with the given arguments.
  class RemoteRecordNotFound < ActiveRemoteError
    attr_accessor :remote_record_class

    def initialize(class_or_message = "")
      message = class_or_message

      if class_or_message.is_a?(Class)
        self.remote_record_class = class_or_message
        message = "#{remote_record_class} does not exist"
      end

      super(message)
    end
  end

  # Raised by ActiveRemove::Base.save! and ActiveRemote::Base.create! methods
  # when remote record cannot be saved because it is invalid.
  class RemoteRecordNotSaved < ActiveRemoteError
  end

  class UnknownAttributeError < ActiveRemoteError
  end
end
