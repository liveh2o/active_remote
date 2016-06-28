require "spec_helper"

describe "attribute defailts" do
  let(:test_class) { ::DefaultAuthor }

  describe "string" do
    it "defaults to a string" do
      record = test_class.new
      expect(record.name).to eq("John Doe")
    end
  end

  describe "lambda" do
    it "calls the lambda" do
      record = test_class.new
      expect(record.guid).to eq(100)
    end
  end

  describe "array" do
    it "defaults to an array" do
      record = test_class.new
      expect(record.books).to eq([])
    end
  end
end
