class TypecastedAuthor < ::ActiveRemote::Base
  attribute :guid, :string
  attribute :name, :string
  attribute :age, :integer
  attribute :birthday, :datetime
  attribute :writes_fiction, :boolean
  attribute :net_sales, :float
end
