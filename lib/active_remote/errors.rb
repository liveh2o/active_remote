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
  end

  # Raised by ActiveRemove::Base.save! and ActiveRemote::Base.create! methods
  # when remote record cannot be saved because it is invalid.
  class RemoteRecordNotSaved < ActiveRemoteError
  end

  # TODO: Create more specific errors
  #
end
