require "support/protobuf/author.pb"

##
# Define a generic class that inherits from active remote base
#
class Author < ::ActiveRemote::Base
  service_class ::Generic::Remote::AuthorService

  attribute :guid
  attribute :name
  attribute :user_guid
  attribute :chief_editor_guid
  attribute :editor_guid
  attribute :category_guid

  has_many :posts
  has_many :user_posts, :class_name => "::Post", :scope => :user_guid
  has_many :flagged_posts, :class_name => "::Post"
  has_many :bestseller_posts, :class_name => "::Post", :foreign_key => :bestseller_guid

  belongs_to :category
end
