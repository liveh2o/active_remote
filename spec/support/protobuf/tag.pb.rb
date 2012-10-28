##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'
require 'protobuf/rpc/service'

##
# Imports
#
require 'support/protobuf/error.pb'

module Generic
  module Remote
    
    ##
    # Message Classes
    #
    class Tag < ::Protobuf::Message; end
    class Tags < ::Protobuf::Message; end
    class TagRequest < ::Protobuf::Message; end
    
    ##
    # Message Fields
    #
    class Tag
      optional ::Protobuf::Field::StringField, :guid, 1
      optional ::Protobuf::Field::StringField, :name, 2
      repeated ::Generic::Error, :errors, 3
    end
    
    class Tags
      repeated ::Generic::Remote::Tag, :records, 1
    end
    
    class TagRequest
      repeated ::Protobuf::Field::StringField, :guid, 1
      repeated ::Protobuf::Field::StringField, :name, 2
    end
    
    ##
    # Services
    #
    class TagService < ::Protobuf::Rpc::Service
      rpc :search, ::Generic::Remote::TagRequest, ::Generic::Remote::Tags
      rpc :create, ::Generic::Remote::Tag, ::Generic::Remote::Tag
      rpc :update, ::Generic::Remote::Tag, ::Generic::Remote::Tag
      rpc :delete, ::Generic::Remote::Tag, ::Generic::Remote::Tag
      rpc :create_all, ::Generic::Remote::Tags, ::Generic::Remote::Tags
      rpc :update_all, ::Generic::Remote::Tags, ::Generic::Remote::Tags
      rpc :delete_all, ::Generic::Remote::Tags, ::Generic::Remote::Tags
      rpc :destroy_all, ::Generic::Remote::Tags, ::Generic::Remote::Tags
    end
  end
end
