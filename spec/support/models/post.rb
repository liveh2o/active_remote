require 'support/protobuf/post.pb'

##
# Define a generic class that inherits from active remote base
#
class Post < ::ActiveRemote::Base
  service_class ::Generic::Remote::PostService

  attribute :guid
  attribute :name
  attribute :author_guid

  belongs_to :author
  has_one :category

end
