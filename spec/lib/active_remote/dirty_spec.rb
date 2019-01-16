require "spec_helper"

describe ActiveRemote::Dirty do
  context "when writing attributes through the setter" do
    subject { Post.new(:name => "foo") }

    before {
      subject.previous_changes.try(:clear)
      subject.changed_attributes.try(:clear)
    }

    context "when the value changes" do
      before { subject.name = "bar" }

      its(:name_changed?) { should be_truthy }
    end

    context "when the value doesn't change" do
      before { subject.name = "foo" }

      its(:name_changed?) { should be_falsey }
    end
  end

  context "when writing attributes directly" do
    subject { Post.new(:name => "foo") }

    before {
      subject.previous_changes.try(:clear)
      subject.changed_attributes.try(:clear)
    }

    context "when the value changes" do
      before { subject[:name] = "bar" }

      its(:name_changed?) { should be_truthy }
    end

    context "when the value doesn't change" do
      before { subject[:name] = "foo" }

      its(:name_changed?) { should be_falsey }
    end
  end

  describe "#reload" do
    subject { Post.new(:name => "foo") }

    before {
      allow(Post).to receive(:find).and_return(Post.new(:name => "foo"))
      subject.reload
    }

    its(:changes) { should be_empty }
  end

  describe "#remote" do
    let(:post) { Post.new(:name => "foo") }

    it "clears changes information" do
      allow(post).to receive(:remote_call).and_return(::Generic::Remote::Post.new(:name => "foo"))
      expect { post.remote(:reload) }.to change { post.changed? }.to(false)
    end
  end

  describe "#save" do
    let!(:changes) { subject.changes }

    subject { Post.new(:name => "foo") }

    before {
      allow(subject).to receive(:create_or_update).and_return(true)
      subject.save
    }

    its(:previous_changes) { should eq changes }
    its(:changes) { should be_empty }
  end

  describe "#save!" do
    let!(:changes) { subject.changes }

    subject { Post.new(:name => "foo") }

    before {
      allow(subject).to receive(:save).and_return(true)
      subject.save!
    }

    its(:previous_changes) { should eq changes }
    its(:changes) { should be_empty }
  end

  describe "#instantiate" do
    let(:post) { Post.new }
    let(:record) { ::Generic::Remote::Post.new(:name => "foo") }

    it "clears previous changes" do
      new_record = post.instantiate(record.to_hash)
      expect(new_record.previous_changes).to eq({})
    end

    it "clears changes" do
      new_record = post.instantiate(record.to_hash)
      expect(new_record.changes).to be_empty
    end
  end
end
