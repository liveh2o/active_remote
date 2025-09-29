require "spec_helper"

RSpec.describe ::ActiveRemote::AttributeMethods do
  describe "#attribute_for_inspect" do
    it "returns the inspect-like string for the attribute" do
      tag = Tag.new(guid: "derp")
      expect(tag.attribute_for_inspect("guid")).to eq("derp".inspect)
    end

    context "when the attribute is a string longer than 50 characters" do
      it "returns the inspect-like string for the attribute" do
        tag = Tag.new(name: "The lazy yellow dog was caught by the slow red fox as he lay sleeping in the sun")
        expect(tag.attribute_for_inspect("name")).to eq("The lazy yellow dog was caught by the slow red fox...".inspect)
      end
    end

    context "when the attribute is a Date" do
      it "returns the inspect-like string in the :db format" do
        value = Date.today
        tag = Tag.new(updated_at: value)
        expect(tag.attribute_for_inspect("updated_at")).to eq(%("#{value.to_fs(:db)}"))
      end
    end

    context "when the attribute is a Time" do
      it "returns the inspect-like string in the :db format" do
        value = Time.current
        tag = Tag.new(updated_at: value)
        expect(tag.attribute_for_inspect("updated_at")).to eq(%("#{value.to_fs(:db)}"))
      end
    end
  end
end
