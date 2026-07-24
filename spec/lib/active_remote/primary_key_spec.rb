require "spec_helper"

RSpec.describe ActiveRemote::PrimaryKey do
  after { Tag._primary_key = nil }

  describe ".default_primary_key" do
    it "returns array of :guid" do
      expect(Tag.default_primary_key).to eq(:guid)
    end
  end

  describe "primary_key" do
    context "when no arguments are passed" do
      it "returns default primary key" do
        expect(Tag.primary_key).to eq(:guid)
      end
    end

    context "when arguments are passed" do
      let(:specified_primary_key) { :name }

      it "returns the given primary key" do
        expect(Tag.primary_key(specified_primary_key)).to eq(specified_primary_key)
      end
    end

    context "when a superclass declares one" do
      let(:parent) do
        Class.new(ActiveRemote::Base) do
          primary_key :uuid
          attribute :uuid, :string
        end
      end

      it "is inherited by subclasses" do
        expect(Class.new(parent).primary_key).to eq(:uuid)
      end

      it "can still be overridden by the subclass" do
        child = Class.new(parent) { primary_key :other }

        expect(child.primary_key).to eq(:other)
        expect(parent.primary_key).to eq(:uuid)
      end
    end
  end

  describe "#primary_key" do
    it "returns the primary key for the class" do
      expect(Tag.new.primary_key).to eq Tag.primary_key
    end
  end

  describe "#to_key" do
    context "when no primary key is specified and default of guid does not exist" do
      it "returns nil" do
        expect(NoAttributes.new.to_key).to eq nil
      end
    end

    context "when no primary key is specified, but default of guid exists" do
      it "returns guid in array" do
        expect(Tag.new(guid: "TAG-123").to_key).to eq ["TAG-123"]
      end
    end

    it "reflects a reassigned primary key rather than memoizing the first read" do
      tag = Tag.new(guid: "TAG-123")
      tag.to_key
      tag.guid = "TAG-456"

      expect(tag.to_key).to eq ["TAG-456"]
    end
  end
end
