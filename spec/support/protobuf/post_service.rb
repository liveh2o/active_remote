require 'protobuf/rpc/service'
require 'support/protobuf/post.pb'

# Define a generic RPC service
#
module Generic
  module Remote
    class PostService < Protobuf::Rpc::Service
      rpc :search, PostRequest, Posts
      rpc :create, Post, Post
      rpc :update, Post, Post
      rpc :delete, Post, Post
      rpc :create_all, Posts, Posts
      rpc :update_all, Posts, Posts
      rpc :delete_all, Posts, Posts
      rpc :destroy_all, Posts, Posts
    end
  end
end
