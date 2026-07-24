require "spec_helper"

RSpec.describe ActiveRemote::Base do
  describe "#initialize" do
    it "runs callbacks" do
      expect_any_instance_of(described_class).to receive(:run_callbacks).with(:initialize)
      described_class.new
    end
  end

  # #eql? is aliased to #==, so #hash has to agree.
  describe "#hash" do
    it "matches for two records with the same class and primary key" do
      expect(Tag.new(guid: "1").hash).to eq(Tag.new(guid: "1").hash)
    end

    it "lets equal records collapse in a Set, #uniq and as Hash keys" do
      a = Tag.new(guid: "1")
      b = Tag.new(guid: "1")

      expect([a, b].uniq.size).to eq(1)
      expect({a => :found}[b]).to eq(:found)
    end

    it "differs for the same key on another class" do
      expect(Tag.new(guid: "1").hash).not_to eq(Author.new(guid: "1").hash)
    end

    it "falls back to identity for new records, matching #==" do
      expect([Tag.new, Tag.new].uniq.size).to eq(2)
    end
  end

  describe "#== and #eql?" do
    let(:tag) { Tag.new(guid: "1") }

    it "is equal when the class and primary key match" do
      expect(tag).to eq(Tag.new(guid: "1"))
      expect(tag).to eql(Tag.new(guid: "1"))
    end

    it "is not equal when the primary key differs" do
      expect(tag).not_to eq(Tag.new(guid: "2"))
    end

    it "considers two new records unequal" do
      expect(Tag.new).not_to eq(Tag.new)
    end

    it "is not equal to an instance of another class with the same key" do
      expect(tag).not_to eq(Author.new(guid: "1"))
    end

    it "is not equal to nil" do
      expect(tag).not_to eq(nil)
    end

    it "is not equal to a bare value matching the key" do
      expect(tag).not_to eq("1")
    end
  end

  describe "#<=>" do
    it "sorts records of the same class by key" do
      a = Tag.new(guid: "1")
      b = Tag.new(guid: "2")
      expect([b, a].sort).to eq([a, b])
    end

    it "returns nil when compared to another type" do
      expect(Tag.new(guid: "1") <=> "1").to be_nil
    end

    it "returns nil when compared to another ActiveRemote class" do
      expect(Tag.new(guid: "1") <=> Author.new(guid: "1")).to be_nil
    end
  end

  describe "#freeze and #frozen?" do
    it "freezes the record's attributes" do
      expect(Tag.new(guid: "1").freeze).to be_frozen
    end

    it "reports an unfrozen record as not frozen" do
      expect(Tag.new(guid: "1")).not_to be_frozen
    end

    it "prevents further writes once frozen" do
      tag = Tag.new(guid: "1").freeze
      expect { tag.name = "nope" }.to raise_error(FrozenError)
    end

    # An RPC response swaps out @attributes, which used to silently thaw the record.
    it "freezes the object itself, not just the attribute set" do
      tag = Tag.new(guid: "1").freeze

      expect(Object.instance_method(:frozen?).bind_call(tag)).to be(true)
    end

    it "does not report an allocated-but-uninitialized record as frozen" do
      expect(Tag.allocate).not_to be_frozen
    end
  end

  describe "#init_with" do
    it "builds a persisted record from an attributes set" do
      built = Tag.allocate.init_with(Tag.build_from_rpc(guid: "Z"))

      expect(built.new_record?).to be(false)
      expect(built.guid).to eq("Z")
    end
  end

  describe "#inspect" do
    it "shows the value for a set attribute" do
      expect(Tag.new(guid: "I").inspect).to include('guid: "I"')
    end

    it "shows only the name for an unset attribute" do
      inspection = Tag.new(guid: "I").inspect

      expect(inspection).to include("user_guid")
      expect(inspection).not_to include("user_guid:")
    end

    it "reports an uninitialized instance" do
      expect(Tag.allocate.inspect).to eq("#<Tag not initialized>")
    end
  end

  describe "#slice" do
    it "returns the requested attributes with indifferent access" do
      result = Tag.new(guid: "S", name: "nm").slice(:guid, :name)

      expect(result[:guid]).to eq("S")
      expect(result["name"]).to eq("nm")
    end

    it "does not include attributes that were not requested" do
      result = Tag.new(guid: "S", name: "nm").slice(:guid)

      expect(result).not_to have_key("name")
    end
  end
end
