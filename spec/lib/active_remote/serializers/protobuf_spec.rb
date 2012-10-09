require 'spec_helper'

describe ActiveRemote::Serializers::Protobuf do
  describe ".build_message" do
    it "coerces the attribute value to a compatible type"

    it "builds a protobuf message"

    context "when the message doesn't have a field matching a given attribute" do
      it "skips the attribute"
    end

    context "when a field is repeated" do
      it "converts the attribute to a collection"
      it "coerces the attribute value(s) to a compatible type"
    end

    context "when the field is an enum" do
      it "converts the attribute into an integer"
    end

    context "when a field is a message" do
      let(:attributes) { { :category => category } }
      let(:category) { { :name  => 'foo' } }
      let(:category_message) { Generic::Remote::Category.new(category) }

      context "and the value is a hash" do
        it "builds new messages with the value(s)" do
          message = ::ActiveRemote::Base.build_message(Generic::Remote::Post, attributes)
          message.category.should eq (category_message)
        end
      end

      context "and the value is a message" do
        let(:attributes) { { :category => category_message } }

        it "returns the value" do
          message = ::ActiveRemote::Base.build_message(Generic::Remote::Post, attributes)
          message.category.should eq (category_message)
        end
      end

      context "and the field is repeated" do
        context "and the value is a hash" do
          let(:attributes) { { :records => [ tag ] } }
          let(:tag) { { :name  => 'foo' } }
          let(:tag_message) { Generic::Remote::Tag.new(tag) }

          it "builds new messages with the value(s)" do
            message = ::ActiveRemote::Base.build_message(Generic::Remote::Tags, attributes)
            message.records.first.should eq (tag_message)
          end
        end

        context "and the value is a message" do
          let(:attributes) { { :records => [ tag_message ] } }
          let(:tag_message) { Generic::Remote::Tag.new }

          it "returns the value" do
            message = ::ActiveRemote::Base.build_message(Generic::Remote::Tags, attributes)
            message.records.first.should eq (tag_message)
          end
        end
      end
    end
  end

  describe ".coerce" do
    context "when field_type is :bool" do
      context "and value is 1" do
        it "returns true"
      end

      context "and value is 0" do
        it "returns false"
      end
    end

    context "when the field_type is :int32" do
      it "returns an integer"
    end

    context "when the field_type is :int64" do
      it "returns an integer"
    end

    context "when the field_type is :double" do
      it "returns a float"
    end

    context "when the field_type is :string" do
      it "returns a string"
    end
  end
end
