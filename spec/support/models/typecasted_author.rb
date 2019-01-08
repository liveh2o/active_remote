class TypecastedAuthor < ::ActiveRemote::Base
  attribute :guid, :type => String
  attribute :name, :typecaster => StringTypecaster
  attribute :age, :integer
  attribute :birthday, :type => DateTime
  attribute :writes_fiction, :boolean
  attribute :net_sales, :typecaster => FloatTypecaster
end
