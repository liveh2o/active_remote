require 'support/protobuf/author.pb'

##
# Define a generic class that inherits from active remote base
#
class DefaultAuthor < ::ActiveRemote::Base
  service_class ::Generic::Remote::AuthorService

  attribute :guid, :default => lambda { 100 }
  attribute :name, :default => "John Doe"
  attribute :books, :default => []
end
