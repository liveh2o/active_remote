require "support/protobuf/post.pb"

##
# Define a generic class that inherits from active remote base
#
class User < ::ActiveRemote::Base
  attribute :password, :string

  filtered_attributes :password
end
