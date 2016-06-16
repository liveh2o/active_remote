class TypecastedAuthor < ::ActiveRemote::Base
  attribute :guid, :type => String
  attribute :name, :typecaster => StringTypecaster
  attribute :age, :type => Integer
  attribute :birthday, :type => DateTime
  attribute :writes_fiction, :type => Boolean
  attribute :net_sales, :type => Float
end
