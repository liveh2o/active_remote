require "spec_helper"

describe ::ActiveRemote::AttributeAssignment do
  let(:model_class) do
    ::Class.new(::ActiveRemote::Base) do
      attribute :name
      attribute :address
    end
  end
  subject { model_class.new }

  describe "#reset_attributes" do
    it "resets all attributes back to the default attribute hash" do
      subject.assign_attributes(:name => "Testing", :address => "123 Yolo St")
      expect(subject.attributes).to eq({"name" => "Testing", "address" => "123 Yolo St"})
      subject.reset_attributes
      expect(subject.attributes).to eq({"name" => nil, "address" => nil})
    end
  end
end
