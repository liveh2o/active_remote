require 'spec_helper'

describe ActiveRemote::Association do
  let(:record) { double(:record) }
  let(:records) { [ record ] }

  describe '.belongs_to' do
    let(:author_guid) { 'AUT-123' }

    subject { Post.new(:author_guid => author_guid) }
    it { should respond_to(:author) }

    it 'searches the associated model for a single record' do
      Author.should_receive(:search).with(:guid => subject.author_guid).and_return(records)
      subject.author.should eq record
    end

    it 'memoizes the result record' do
      Author.should_receive(:search).once.with(:guid => subject.author_guid).and_return(records)
      3.times { subject.author.should eq record }
    end

    context 'when the search is empty' do
      it 'returns a nil' do
        Author.should_receive(:search).with(:guid => subject.author_guid).and_return([])
        subject.author.should be_nil
      end
    end
  end

  describe '.has_many' do
    let(:records) { [ record, record, record ] }
    let(:guid) { 'AUT-123' }

    subject { Author.new(:guid => guid) }
    it { should respond_to(:posts) }

    it 'searches the associated model for all associated records' do
      Post.should_receive(:search).with(:author_guid => subject.guid).and_return(records)
      subject.posts.should eq records
    end

    it 'memoizes the result record' do
      Post.should_receive(:search).once.with(:author_guid => subject.guid).and_return(records)
      3.times { subject.posts.should eq records }
    end

    context 'when the search is empty' do
      it 'returns the empty set' do
        Post.should_receive(:search).with(:author_guid => subject.guid).and_return([])
        subject.posts.should be_empty
      end
    end
  end

  describe '.has_one' do
    let(:guid) { 'PST-123' }

    subject { Post.new(:guid => guid) }
    it { should respond_to(:category) }

    it 'searches the associated model for all associated records' do
      Category.should_receive(:search).with(:post_guid => subject.guid).and_return(records)
      subject.category.should eq record
    end

    it 'memoizes the result record' do
      Category.should_receive(:search).once.with(:post_guid => subject.guid).and_return(records)
      3.times { subject.category.should eq record }
    end

    context 'when the search is empty' do
      it 'returns a nil value' do
        Category.should_receive(:search).with(:post_guid => subject.guid).and_return([])
        subject.category.should be_nil
      end
    end
  end

end
