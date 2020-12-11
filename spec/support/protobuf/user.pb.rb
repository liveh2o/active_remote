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
    class User < ::Protobuf::Message; end

    ##
    # Message Fields
    #
    class User
      optional :string, :password, 1
      optional :string, :password_digest, 2
    end
  end
end
