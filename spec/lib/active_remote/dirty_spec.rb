require "spec_helper"

RSpec.describe ActiveRemote::Dirty do
  context "#attribute=" do
    subject(:post) { Post.new(name: "foo") }

    before { reset_changes(post) }

    context "when the value changes" do
      it "tracks changes" do
        post.name = "bar"
        expect(post.name_changed?).to be(true)
      end
    end

    context "when the value doesn't change" do
      it "tracks changes" do
        post.name = "foo"
        expect(post.name_changed?).to be(false)
      end
    end
  end

  describe "#[]=" do
    subject(:post) { Post.new(name: "foo") }

    before { reset_changes(post) }

    context "when the value changes" do
      it "tracks changes" do
        post[:name] = "bar"
        expect(post.name_changed?).to be(true)
      end
    end

    context "when the value doesn't change" do
      it "tracks changes" do
        post[:name] = "foo"
        expect(post.name_changed?).to be(false)
      end
    end
  end

  describe "#reload" do
    let(:post) { Post.new(name: "foo") }

    it "clears changes information" do
      allow(Post).to receive(:find).and_return(Post.new(name: "foo"))
      expect { post.reload }.to change { post.changed? }.to(false)
    end
  end

  describe "#remote" do
    let(:post) { Post.new(name: "foo") }

    it "clears changes information" do
      allow(post).to receive(:remote_call).and_return(::Generic::Remote::Post.new(name: "foo"))
      expect { post.remote(:reload) }.to change { post.changed? }.to(false)
    end
  end

  describe "#instantiate" do
    let(:post) { Post.new(name: "foo") }

    # #instantiate swaps @attributes, orphaning the mutation tracker unless reset.
    it "clears changes information" do
      expect { post.instantiate("name" => "bar") }.to change { post.changed? }.to(false)
    end
  end

  # Stub at the RPC boundary: stubbing `create_or_update` or `save` skips
  # `#remote`, which is what replaces @attributes with the service response.
  describe "#save" do
    subject(:post) { Post.new(name: "foo") }

    before do
      allow(post).to receive(:remote_call).and_return(::Generic::Remote::Post.new(name: "foo"))
    end

    it "applies changes" do
      changes = post.changes
      post.save
      expect(post.previous_changes).to eq(changes)
      expect(post.changes).to be_empty
    end
  end

  describe "#save!" do
    subject(:post) { Post.new(name: "foo") }

    before do
      allow(post).to receive(:remote_call).and_return(::Generic::Remote::Post.new(name: "foo"))
    end

    it "applies changes" do
      changes = post.changes
      post.save!
      expect(post.previous_changes).to eq(changes)
      expect(post.changes).to be_empty
    end
  end

  # Dirty tracking compares cast values, which only typed attributes reveal.
  describe "cast-aware change tracking" do
    subject(:author) { Author.new(age: 42, writes_fiction: true) }

    before { reset_changes(author) }

    context "when a raw value casts equal to the current value" do
      it "does not mark an integer attribute changed" do
        author.age = "42" # String that casts to the stored Integer 42
        expect(author.age_changed?).to be(false)
      end

      it "does not mark a boolean attribute changed" do
        author.writes_fiction = "t" # casts to the stored true
        expect(author.writes_fiction_changed?).to be(false)
      end

      it "is cast-aware through #[]= as well" do
        author[:age] = "42"
        expect(author.age_changed?).to be(false)
      end
    end

    context "when a raw value casts to a different value" do
      it "marks the attribute changed, casting both endpoints" do
        author.age = "43"
        expect(author.age_change).to eq([42, 43])
      end
    end
  end

  describe "change tracking on a new record" do
    it "reports assigned attributes as changes, cast to their type" do
      author = Author.new(age: "5")

      expect(author.changes).to eq("age" => [nil, 5])
    end
  end
end
