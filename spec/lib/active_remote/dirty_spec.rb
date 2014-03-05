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

  describe "#serialize_records" do
    let(:post) { Post.new }
    let(:record) { ::Generic::Remote::Post.new(:name => 'foo') }
    let(:response) { double(:response, :records => [ record ]) }

    before {
      post.stub(:last_response).and_return(response)
    }

    it "clears previous changes" do
      records = post.serialize_records
      records.first.previous_changes.should be_nil
    end

    it "clears changes" do
      records = post.serialize_records
      records.first.changes.should be_empty
    end
  end
end
