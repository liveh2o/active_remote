require "spec_helper"

RSpec.describe "ActiveRemote attribute type casting" do
  subject(:author) { Author.new }

  describe ":integer" do
    it "casts assigned strings to Integer" do
      author.age = "42"
      expect(author.age).to eq(42)
      expect(author.age).to be_a(Integer)
    end

    it "truncates floats rather than rounding" do
      author.age = 3.9
      expect(author.age).to eq(3)
    end

    it "casts blank to nil" do
      author.age = ""
      expect(author.age).to be_nil
    end

    it "does not preserve a non-numeric string" do
      author.age = "not a number"
      expect(author.age).to eq(0)
    end
  end

  describe ":boolean" do
    it "casts truthy strings to true" do
      author.writes_fiction = "t"
      expect(author.writes_fiction).to be(true)
    end

    it "casts falsey strings to false" do
      author.writes_fiction = "f"
      expect(author.writes_fiction).to be(false)
    end

    it "casts \"0\" to false" do
      author.writes_fiction = "0"
      expect(author.writes_fiction).to be(false)
    end

    it "leaves nil as nil rather than coercing to false" do
      author.writes_fiction = nil
      expect(author.writes_fiction).to be_nil
    end
  end

  describe ":float" do
    it "casts assigned strings to Float" do
      author.net_sales = "1.5"
      expect(author.net_sales).to eq(1.5)
      expect(author.net_sales).to be_a(Float)
    end

    it "does not preserve a non-numeric string" do
      author.net_sales = "abc"
      expect(author.net_sales).to eq(0.0)
    end
  end

  describe ":datetime" do
    it "casts assigned strings to a Time" do
      author.birthday = "2020-01-01"
      expect(author.birthday).to be_a(Time)
      expect(author.birthday.year).to eq(2020)
    end

    it "casts an unparseable string to nil" do
      author.birthday = "not a date"
      expect(author.birthday).to be_nil
    end
  end

  describe ".attribute_types" do
    it "exposes the declared type for an attribute" do
      expect(Author.attribute_types["age"]).to be_a(ActiveModel::Type::Integer)
    end

    it "does not report an undeclared attribute" do
      expect(Author.attribute_types).not_to have_key("bogus")
    end
  end

  describe ".attribute_names" do
    it "lists all declared attribute names" do
      expect(Author.attribute_names).to include("guid", "age", "writes_fiction")
    end

    it "does not list undeclared attributes" do
      expect(Author.attribute_names).not_to include("bogus")
    end
  end

  describe "unknown attributes" do
    it "raises when assigned via the constructor" do
      expect { Author.new(bogus: 1) }.to raise_error(ActiveModel::UnknownAttributeError)
    end
  end
end
