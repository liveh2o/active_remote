##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'
require 'protobuf/rpc/service'


##
# Imports
#
require 'support/protobuf/error.pb'
require 'support/protobuf/category.pb'

module Generic
  module Remote

    ##
    # Message Classes
    #
    class Post < ::Protobuf::Message; end
    class Posts < ::Protobuf::Message; end
    class PostRequest < ::Protobuf::Message; end


    ##
    # Message Fields
    #
    class Post
      optional ::Protobuf::Field::StringField, :guid, 1
      optional ::Protobuf::Field::StringField, :name, 2
      optional ::Protobuf::Field::StringField, :author_guid, 3
      optional ::Generic::Remote::Category, :category, 4
      repeated ::Generic::Error, :errors, 5
      optional ::Protobuf::Field::StringField, :user_guid, 6
    end

    class Posts
      repeated ::Generic::Remote::Post, :records, 1
    end

    class PostRequest
      repeated ::Protobuf::Field::StringField, :guid, 1
      repeated ::Protobuf::Field::StringField, :name, 2
      repeated ::Protobuf::Field::StringField, :author_guid, 3
      repeated ::Protobuf::Field::StringField, :user_guid, 4
    end


    ##
    # Service Classes
    #
    class PostService < ::Protobuf::Rpc::Service
      rpc :search, ::Generic::Remote::PostRequest, ::Generic::Remote::Posts
      rpc :create, ::Generic::Remote::Post, ::Generic::Remote::Post
      rpc :update, ::Generic::Remote::Post, ::Generic::Remote::Post
      rpc :delete, ::Generic::Remote::Post, ::Generic::Remote::Post
      rpc :create_all, ::Generic::Remote::Posts, ::Generic::Remote::Posts
      rpc :update_all, ::Generic::Remote::Posts, ::Generic::Remote::Posts
      rpc :delete_all, ::Generic::Remote::Posts, ::Generic::Remote::Posts
      rpc :destroy_all, ::Generic::Remote::Posts, ::Generic::Remote::Posts
    end

  end

end

