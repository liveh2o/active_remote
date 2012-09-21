require 'protobuf/rpc/service'
require 'support/protobuf/category.pb'

# Define a generic RPC service
#
module Generic
  module Remote
    class CategoryService < Protobuf::Rpc::Service
      rpc :search, CategoryRequest, Categories
      rpc :create, Category, Category
      rpc :update, Category, Category
      rpc :delete, Category, Category
      rpc :create_all, Categories, Categories
      rpc :update_all, Categories, Categories
      rpc :delete_all, Categories, Categories
      rpc :destroy_all, Categories, Categories
    end
  end
end
