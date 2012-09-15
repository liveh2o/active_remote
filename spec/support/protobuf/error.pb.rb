require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'

module Generic
  class Error < ::Protobuf::Message
    optional :string, :field, 1
    optional :string, :message, 2
  end
end
