require 'spec_helper'

describe ActiveRemote::Dirty do
  context "when writing attributes through the setter" do
    subject { Post.new(:name => 'foo') }

    before {
      subject.previous_changes.try(:clear)
      subject.changed_attributes.try(:clear)
    }

    context "when the value changes" do
      before { subject.name = 'bar' }

      its(:name_changed?) { should be_true }
    end

    context "when the value doesn't change" do
      before { subject.name = 'foo' }

      its(:name_changed?) { should be_false }
    end
  end

  context "when writing attributes directly" do
    subject { Post.new(:name => 'foo') }

    before {
      subject.previous_changes.try(:clear)
      subject.changed_attributes.try(:clear)
    }

    context "when the value changes" do
      before { subject[:name] = 'bar' }

      its(:name_changed?) { should be_true }
    end

    context "when the value doesn't change" do
      before { subject[:name] = 'foo' }

      its(:name_changed?) { should be_false }
    end
  end

  describe "#reload" do
    subject { Post.new(:name => 'foo') }

    before {
      Post.stub(:find).and_return({})
      subject.reload
    }

    its(:changes) { should be_empty }
  end

  describe "#save" do
    let!(:changes) { subject.changes }

    subject { Post.new(:name => 'foo') }

    before {
      subject.stub(:create_or_update).and_return(true)
      subject.save
    }

    its(:previous_changes) { should eq changes }
    its(:changes) { should be_empty }
  end

  describe "#save!" do
    let!(:changes) { subject.changes }

    subject { Post.new(:name => 'foo') }

    before {
      subject.stub(:save).and_return(true)
      subject.save!
    }

    its(:previous_changes) { should eq changes }
    its(:changes) { should be_empty }
  end

  describe "#instantiate" do
    let(:post) { Post.new }
    let(:record) { ::Generic::Remote::Post.new(:name => 'foo') }

    it "clears previous changes" do
      new_record = post.instantiate(record.to_hash)
      new_record.previous_changes.should eq({})
    end

    it "clears changes" do
      new_record = post.instantiate(record.to_hash)
      new_record.changes.should be_empty
    end
  end
end
