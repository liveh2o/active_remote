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
      it "builds a new message with the attribute"

      context "and the field is repeated" do
        it "builds new messages with the attribute value(s)"
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
