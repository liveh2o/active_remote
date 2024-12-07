require "spec_helper"

RSpec.describe ActiveRemote::Dirty do
  context "#attribute=" do
    subject(:post) { Post.new(name: "foo") }

    before do
      post.changes_applied
      post.clear_changes_information
    end

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

    before do
      subject.changes_applied
      subject.clear_changes_information
    end

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

  describe "#save" do
    subject(:post) { Post.new(name: "foo") }

    before do
      allow(post).to receive(:create_or_update).and_return(true)
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
      allow(post).to receive(:save).and_return(true)
    end

    it "applies changes" do
      changes = post.changes
      post.save!
      expect(post.previous_changes).to eq(changes)
      expect(post.changes).to be_empty
    end
  end
end
