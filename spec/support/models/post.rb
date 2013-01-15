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
  belongs_to :coauthor, :class_name => '::Author'
  belongs_to :bestseller, :class_name => '::Author', :foreign_key => :bestseller_guid
  has_one :category
  has_one :main_category, :class_name => '::Category'
  has_one :default_category, :class_name => '::Category', :foreign_key => :template_post_guid

  alias_method :bestseller_guid, :author_guid
end
