require 'support/protobuf/category_service'

##
# Define a generic class that inherits from active remote base
#
class Category < ::ActiveRemote::Base
  service_class ::Generic::Remote::CategoryService

  attribute :guid
  attribute :name

  belongs_to :post

end
