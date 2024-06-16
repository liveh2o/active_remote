##
# This file is auto-generated. DO NOT EDIT!
#
require "protobuf"

module Generic
  ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

  ##
  # Message Classes
  #
  class Error < ::Protobuf::Message; end

  ##
  # Message Fields
  #
  class Error
    optional :string, :field, 1
    optional :string, :message, 2
  end
end
