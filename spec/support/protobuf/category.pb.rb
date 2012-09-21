require 'protobuf/message/message'
require 'protobuf/message/enum'
require 'protobuf/message/extend'

module Generic
  module Remote
    require 'support/protobuf/error.pb'

    class Category < ::Protobuf::Message
      optional :string, :guid, 1
      optional :string, :name, 2
      repeated :Error, :errors, 3
    end
    class Categories < ::Protobuf::Message
      repeated :Category, :records, 1
    end
    class CategoryRequest < ::Protobuf::Message
      repeated :string, :guid, 1
      repeated :string, :name, 2
    end
  end
end
