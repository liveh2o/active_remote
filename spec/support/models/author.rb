require 'support/protobuf/author.pb'

##
# Define a generic class that inherits from active remote base
#
class Author < ::ActiveRemote::Base
  service_class ::Generic::Remote::AuthorService

  attribute :guid
  attribute :name

  has_many :posts

end
