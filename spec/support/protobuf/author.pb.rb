##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'
require 'protobuf/rpc/service'

##
# Imports
#
require 'error.pb'

module Generic
  module Remote
    
    ##
    # Message Classes
    #
    class Author < ::Protobuf::Message; end
    class Authors < ::Protobuf::Message; end
    class AuthorRequest < ::Protobuf::Message; end
    
    ##
    # Message Fields
    #
    class Author
      optional ::Protobuf::Field::StringField, :guid, 1
      optional ::Protobuf::Field::StringField, :name, 2
      repeated ::Generic::Error, :errors, 3
    end
    
    class Authors
      repeated ::Generic::Remote::Author, :records, 1
    end
    
    class AuthorRequest
      repeated ::Protobuf::Field::StringField, :guid, 1
      repeated ::Protobuf::Field::StringField, :name, 2
    end
    
    ##
    # Services
    #
    class AuthorService < ::Protobuf::Rpc::Service
      rpc :search, ::Generic::Remote::AuthorRequest, ::Generic::Remote::Authors
      rpc :create, ::Generic::Remote::Author, ::Generic::Remote::Author
      rpc :update, ::Generic::Remote::Author, ::Generic::Remote::Author
      rpc :delete, ::Generic::Remote::Author, ::Generic::Remote::Author
      rpc :create_all, ::Generic::Remote::Authors, ::Generic::Remote::Authors
      rpc :update_all, ::Generic::Remote::Authors, ::Generic::Remote::Authors
      rpc :delete_all, ::Generic::Remote::Authors, ::Generic::Remote::Authors
      rpc :destroy_all, ::Generic::Remote::Authors, ::Generic::Remote::Authors
    end
  end
end
