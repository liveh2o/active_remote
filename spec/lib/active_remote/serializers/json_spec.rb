require 'spec_helper'

describe ActiveRemote::Serializers::JSON do
  describe "#as_json" do
    let(:attributes) { { :guid => 'foo', :name => 'bar', :updated_at => nil, :user_guid => 'baz' } }
    let(:serializable_attributes) { { "tag" => attributes.stringify_keys } }

    subject { Tag.new(attributes) }

    context "with roots in json" do
      context "when options are nil" do
        it "substitutes an empty hash" do
          expect(subject.as_json(nil)).to eq serializable_attributes
        end
      end

      it "accepts standard JSON options" do
        expect(subject.as_json(:root => false)).to eq attributes.stringify_keys
      end

      context "with publishable attributes defined" do
        let(:expected_json) { { :tag => attributes.slice(:name) }.to_json }

        before { Tag.attr_publishable :name }
        after { reset_publishable_attributes(Tag) }

        it "serializes to JSON with only the publishable attributes" do
          expect(subject.to_json).to eq expected_json
        end
      end

      context "without publishable attributes defined" do
        let(:expected_json) { { :tag => attributes }.to_json }

        it "serializes to JSON" do
          expect(subject.to_json).to eq expected_json
        end
      end
    end

    context "without roots in json" do
      let(:serializable_attributes) { attributes.stringify_keys }

      before(:each) do
        ::ActiveRemote.config.include_root_in_json = false
      end

      after(:each) do
        ::ActiveRemote.config.include_root_in_json = true
      end

      context "when options are nil" do
        it "substitutes an empty hash" do
          expect(subject.as_json(nil)).to eq serializable_attributes
        end
      end

      context "with publishable attributes defined" do
        let(:expected_json) { attributes.slice(:name).to_json }

        before { Tag.attr_publishable :name }
        after { reset_publishable_attributes(Tag) }

        it "serializes to JSON with only the publishable attributes" do
          expect(subject.to_json).to eq expected_json
        end
      end

      context "without publishable attributes defined" do
        let(:expected_json) { attributes.to_json }

        it "serializes to JSON" do
          expect(subject.to_json).to eq expected_json
        end
      end
    end
  end
end
