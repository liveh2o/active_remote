# TODO: Create more specific errors
#
module ActiveRemote
  # Generic Active Remote exception class.
  class ActiveRemoteError < StandardError
  end

  class DangerousAttributeError < ActiveRemoteError
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

  # Raised by ActiveRemote::Base.find when remote record is not found when
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
    attr_reader :record

    def initialize(message_or_record = nil)
      message = message_or_record
      if message_or_record.is_a?(::ActiveRemote::Base)
        @record = message_or_record
        message = @record.errors.full_messages.join(", ")
      end
      super(message)
    end
  end

  class UnknownAttributeError < ActiveRemoteError
  end

  # Errors from Protobuf
  class BadRequestDataError < ActiveRemoteError
  end

  class BadRequestProtoError < ActiveRemoteError
  end

  class ServiceNotFoundError < ActiveRemoteError
  end

  class MethodNotFoundError < ActiveRemoteError
  end

  class RpcError < ActiveRemoteError
  end

  class RpcFailedError < ActiveRemoteError
  end

  class InvalidRequestProtoError < ActiveRemoteError
  end

  class BadResponseProtoError < ActiveRemoteError
  end

  class UnknownHostError < ActiveRemoteError
  end

  class IOError < ActiveRemoteError
  end
end
