require "support/protobuf/post.pb"

##
# Define a generic class that inherits from active remote base
#
class Post < ::ActiveRemote::Base
  service_class ::Generic::Remote::PostService

  attribute :guid, :string
  attribute :name, :string
  attribute :author_guid, :string
  attribute :user_guid, :string
  attribute :bestseller_guid, :string

  belongs_to :author
  belongs_to :coauthor, :class_name => "::Author"
  belongs_to :bestseller, :class_name => "::Author", :foreign_key => :bestseller_guid
  belongs_to :user, :class_name => "::Author", :scope => :user_guid

  validates :name, :presence => true
end
