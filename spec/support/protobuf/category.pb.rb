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
    class Category < ::Protobuf::Message; end
    class Categories < ::Protobuf::Message; end
    class CategoryRequest < ::Protobuf::Message; end
    
    ##
    # Message Fields
    #
    class Category
      optional ::Protobuf::Field::StringField, :guid, 1
      optional ::Protobuf::Field::StringField, :name, 2
      repeated ::Generic::Error, :errors, 3
    end
    
    class Categories
      repeated ::Generic::Remote::Category, :records, 1
    end
    
    class CategoryRequest
      repeated ::Protobuf::Field::StringField, :guid, 1
      repeated ::Protobuf::Field::StringField, :name, 2
    end
    
    ##
    # Services
    #
    class CategoryService < ::Protobuf::Rpc::Service
      rpc :search, ::Generic::Remote::CategoryRequest, ::Generic::Remote::Categories
      rpc :create, ::Generic::Remote::Category, ::Generic::Remote::Category
      rpc :update, ::Generic::Remote::Category, ::Generic::Remote::Category
      rpc :delete, ::Generic::Remote::Category, ::Generic::Remote::Category
      rpc :create_all, ::Generic::Remote::Categories, ::Generic::Remote::Categories
      rpc :update_all, ::Generic::Remote::Categories, ::Generic::Remote::Categories
      rpc :delete_all, ::Generic::Remote::Categories, ::Generic::Remote::Categories
      rpc :destroy_all, ::Generic::Remote::Categories, ::Generic::Remote::Categories
    end
  end
end
