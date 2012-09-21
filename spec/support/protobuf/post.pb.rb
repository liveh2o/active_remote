require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'

module Generic
  module Remote
    require 'support/protobuf/error.pb'

    class Post < ::Protobuf::Message
      optional :string, :guid, 1
      optional :string, :name, 2
      optional :string, :author_guid, 3
      repeated :Error, :errors, 4
    end
    class Posts < ::Protobuf::Message
      repeated :Post, :records, 1
    end
    class PostRequest < ::Protobuf::Message
      repeated :string, :guid, 1
      repeated :string, :name, 2
      repeated :string, :author_guid, 3
    end
  end
end
