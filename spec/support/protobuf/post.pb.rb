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
require 'category.pb'

module Generic
  module Remote
    ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

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
      optional :string, :guid, 1
      optional :string, :name, 2
      optional :string, :author_guid, 3
      optional ::Generic::Remote::Category, :category, 4
      repeated ::Generic::Error, :errors, 5
      optional :string, :user_guid, 6
    end

    class Posts
      repeated ::Generic::Remote::Post, :records, 1
    end

    class PostRequest
      repeated :string, :guid, 1
      repeated :string, :name, 2
      repeated :string, :author_guid, 3
      repeated :string, :user_guid, 4
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

