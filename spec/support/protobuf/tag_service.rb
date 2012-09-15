require 'protobuf/rpc/service'
require 'support/protobuf/tag.pb'

# Define a generic RPC service
#
module Generic
  module Remote
    class TagService < Protobuf::Rpc::Service
      rpc :search, TagRequest, Tags
      rpc :create, Tag, Tag
      rpc :update, Tag, Tag
      rpc :delete, Tag, Tag
      rpc :create_all, Tags, Tags
      rpc :update_all, Tags, Tags
      rpc :delete_all, Tags, Tags
      rpc :destroy_all, Tags, Tags
    end
  end
end
