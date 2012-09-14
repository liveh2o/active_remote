require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'

module Generic
  class Error < ::Protobuf::Message
    optional :string, :message, 1
  end
end
