require 'protobuf/rpc/service'
require 'support/protobuf/author.pb'

# Define a generic RPC service
#
module Generic
  module Remote
    class AuthorService < Protobuf::Rpc::Service
      rpc :search, AuthorRequest, Authors
      rpc :create, Author, Author
      rpc :update, Author, Author
      rpc :delete, Author, Author
      rpc :create_all, Authors, Authors
      rpc :update_all, Authors, Authors
      rpc :delete_all, Authors, Authors
      rpc :destroy_all, Authors, Authors
    end
  end
end
