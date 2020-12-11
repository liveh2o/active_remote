require "support/protobuf/author.pb"

##
# Define a generic class that inherits from active remote base
#
class Author < ::ActiveRemote::Base
  service_class ::Generic::Remote::AuthorService

  attribute :guid, :string
  attribute :name, :string
  attribute :user_guid, :string
  attribute :chief_editor_guid, :string
  attribute :editor_guid, :string
  attribute :category_guid, :string
  attribute :age, :integer
  attribute :birthday, :datetime
  attribute :writes_fiction, :boolean
  attribute :net_sales, :float

  filtered_attributes [:birthday, :age]

  has_many :posts
  has_many :user_posts, :class_name => "::Post", :scope => :user_guid
  has_many :flagged_posts, :class_name => "::Post"
  has_many :bestseller_posts, :class_name => "::Post", :foreign_key => :bestseller_guid

  belongs_to :category
end
