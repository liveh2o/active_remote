require 'support/protobuf/category.pb'

##
# Define a generic class that inherits from active remote base
#
class Category < ::ActiveRemote::Base
  service_class ::Generic::Remote::CategoryService

  attribute :guid
  attribute :name
  attribute :post_id

  belongs_to :post

  alias_method :template_post_guid, :post_id
end
