require 'spec_helper'

describe ActiveRemote::Serializers::JSON do
  describe "#as_json" do
    let(:attributes) { { :guid => 'foo', :name => 'bar', :updated_at => nil } }
    let(:serializable_attributes) { { "tag" => attributes.stringify_keys } }

    subject { Tag.new(attributes) }

    context "when options are nil" do
      it "substitutes an empty hash" do
        subject.as_json(nil).should eq serializable_attributes
      end
    end

    it "accepts standard JSON options" do
      subject.as_json(:root => false).should eq attributes.stringify_keys
    end

    context "with publishable attributes defined" do
      let(:expected_json) { { :tag => attributes.slice(:name) }.to_json }

      before { Tag.attr_publishable :name }
      after { reset_publishable_attributes(Tag) }

      it "serializes to JSON with only the publishable attributes" do
        subject.to_json.should eq expected_json
      end
    end

    context "without publishable attributes defined" do
      let(:expected_json) { { :tag => attributes }.to_json }

      it "serializes to JSON" do
        subject.to_json.should eq expected_json
      end
    end
  end
end
