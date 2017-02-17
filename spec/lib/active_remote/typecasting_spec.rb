require 'spec_helper'
describe ::ActiveRemote::Typecasting do
  let(:test_class) { ::TypecastedAuthor }

  describe "boolean" do
    it "casts to boolean" do
      record = test_class.new(:writes_fiction => "no")
      expect(record.writes_fiction).to eq(false)
    end
  end

  describe "datetime" do
    it "casts to datetime" do
      record = test_class.new(:birthday => "2016-01-01")
      expect(record.birthday).to eq(DateTime.parse("2016-01-01"))
    end
  end

  describe "float" do
    it "casts to float" do
      record = test_class.new(:net_sales => "2000.20")
      expect(record.net_sales).to eq(2000.2)
    end
  end

  describe "integer" do
    it "casts to integer" do
      record = test_class.new(:age => "40")
      expect(record.age).to eq(40)
    end
  end

  describe "string" do
    it "casts to string" do
      record = test_class.new(:guid => 1000)
      expect(record.guid).to eq("1000")
    end
  end
end
