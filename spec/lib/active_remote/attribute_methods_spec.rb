require "spec_helper"

RSpec.describe ::ActiveRemote::AttributeMethods do
  describe "#attribute_for_inspect" do
    it "returns the inspect-like string for the attribute" do
      tag = Tag.new(guid: "derp")
      expect(tag.attribute_for_inspect("guid")).to eq("derp".inspect)
    end

    # Every other example here passes a string, which is what hid this: a symbol
    # used to miss the attribute entirely and report "nil".
    it "accepts a symbol name, as #[] and #[]= do" do
      tag = Tag.new(guid: "derp")
      expect(tag.attribute_for_inspect(:guid)).to eq("derp".inspect)
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

  describe "#[] and #[]=" do
    let(:tag) { Tag.new(guid: "derp") }

    it "reads an attribute by string name" do
      expect(tag["guid"]).to eq("derp")
    end

    it "reads an attribute by symbol name" do
      expect(tag[:guid]).to eq("derp")
    end

    it "writes an attribute by name" do
      tag["name"] = "value"
      expect(tag.name).to eq("value")
    end

    it "casts the value written through []=" do
      author = Author.new
      author["age"] = "7"
      expect(author.age).to eq(7)
    end

    it "returns nil for an unknown attribute rather than raising" do
      expect(tag["bogus"]).to be_nil
    end

    it "raises when writing an unknown attribute through []=" do
      expect { tag["bogus"] = 1 }.to raise_error(ActiveModel::MissingAttributeError)
    end

    context "with an aliased attribute" do
      let(:model) do
        Class.new(ActiveRemote::Base) do
          attribute :guid, :string
          alias_attribute :id, :guid
        end
      end

      it "reads through the alias" do
        expect(model.new(guid: "G")["id"]).to eq("G")
      end

      it "writes through the alias" do
        record = model.new
        record["id"] = "H"
        expect(record.guid).to eq("H")
      end
    end
  end

  describe "#attribute_names" do
    it "returns the names of the instance's attributes" do
      expect(Tag.new.attribute_names).to include("guid", "name", "updated_at", "user_guid")
    end

    it "does not include undeclared attributes" do
      expect(Tag.new.attribute_names).not_to include("bogus")
    end
  end
end
