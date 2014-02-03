# TODO: Create more specific errors
#
module ActiveRemote

  # = Active Remote Errors
  #
  # Generic Active Remote exception class.
  class ActiveRemoteError < StandardError
  end

  # Raised by ActiveRemove::Base.save when the remote record is readonly.
  class ReadOnlyRemoteRecord < ActiveRemoteError
  end

  # Raised by ActiveRemove::Base.find when remote record is not found when
  # searching with the given arguments.
  class RemoteRecordNotFound < ActiveRemoteError
    attr_accessor :remote_record_class

    def initialize(remote_record_class)
      self.remote_record_class = remote_record_class.to_s
      message = "#{remote_record_class} does not exist}"
      super(message)
    end
  end

  # Raised by ActiveRemove::Base.save! and ActiveRemote::Base.create! methods
  # when remote record cannot be saved because it is invalid.
  class RemoteRecordNotSaved < ActiveRemoteError
  end
end
