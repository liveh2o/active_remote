require 'support/protobuf/category.pb'

##
# Define a generic class that inherits from active remote base
#
class Category < ::ActiveRemote::Base
  service_class ::Generic::Remote::CategoryService

  attribute :guid
  attribute :name
  attribute :post_id
  attribute :user_guid
  attribute :template_post_guid

  belongs_to :post

end
