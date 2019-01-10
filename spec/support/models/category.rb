require "support/protobuf/category.pb"

##
# Define a generic class that inherits from active remote base
#
class Category < ::ActiveRemote::Base
  service_class ::Generic::Remote::CategoryService

  attribute :guid
  attribute :user_guid
  attribute :chief_editor_guid

  has_many :posts

  has_one :author
  has_one :senior_author, :class_name => "::Author"
  has_one :primary_editor, :class_name => "::Author", :foreign_key => :editor_guid
  has_one :chief_editor, :class_name => "::Author", :scope => :user_guid, :foreign_key => :chief_editor_guid
end
