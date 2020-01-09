class TypecastedAuthor < ::ActiveRemote::Base
  attribute :guid, :type => String
  attribute :name, :typecaster => StringTypecaster
  attribute :age, :integer
  attribute :birthday, :type => DateTime
  attribute :writes_fiction, :boolean
  attribute :net_sales, :typecaster => FloatTypecaster
  attribute :big_integer_field, :big_integer
end
