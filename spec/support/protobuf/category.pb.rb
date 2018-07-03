# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'
require 'protobuf/rpc/service'


##
# Imports
#
require 'error.pb'

module Generic
  module Remote
    ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

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
      optional :string, :guid, 1
      optional :string, :name, 2
      repeated ::Generic::Error, :errors, 3
      optional :string, :user_guid, 4
      optional :string, :author_guid, 5
      optional :string, :chief_editor_guid, 6
      optional :string, :editor_guid, 7
    end

    class Categories
      repeated ::Generic::Remote::Category, :records, 1
    end

    class CategoryRequest
      repeated :string, :guid, 1
      repeated :string, :name, 2
    end


    ##
    # Service Classes
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

