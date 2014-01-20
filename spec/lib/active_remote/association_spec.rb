require "spec_helper"

describe ActiveRemote::Association do
  let(:record) { double(:record) }
  let(:records) { [ record ] }

  describe ".belongs_to" do
    context "simple association" do
      let(:author_guid) { "AUT-123" }
      let(:user_guid) { "USR-123" }
      let(:default_category_guid) { "CAT-123" }
      subject { Post.new(:author_guid => author_guid, :user_guid => user_guid) }

      it { should respond_to(:author) }

      it "searches the associated model for a single record" do
        Author.should_receive(:search).with(:guid => subject.author_guid).and_return(records)
        subject.author.should eq record
      end

      it "memoizes the result record" do
        Author.should_receive(:search).once.with(:guid => subject.author_guid).and_return(records)
        3.times { subject.author.should eq record }
      end

      context "when guid is nil" do
        subject { Post.new }

        it "returns nil" do
          subject.author.should be_nil
        end
      end

      context "when the search is empty" do
        it "returns a nil" do
          Author.should_receive(:search).with(:guid => subject.author_guid).and_return([])
          subject.author.should be_nil
        end
      end

      context 'scoped field' do
        it { should respond_to(:user) }

        it "searches the associated model for multiple records" do
          Author.should_receive(:search).with(:guid => subject.author_guid, :user_guid => subject.user_guid).and_return(records)
          subject.user.should eq(record)
        end

        context 'when user_guid doesnt exist on model 'do
          before { subject.stub(:respond_to?).with("user_guid").and_return(false) }

          it 'raises an error' do
            expect {subject.user}.to raise_error
          end
        end

        context 'when user_guid doesnt exist on associated model 'do
          before { Author.stub_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

          it 'raises an error' do
            expect {subject.user}.to raise_error
          end
        end
      end

    end

    context "specific association with class name" do
      let(:author_guid) { "AUT-456" }

      subject { Post.new(:author_guid => author_guid) }
      it { should respond_to(:coauthor) }

      it "searches the associated model for a single record" do
        Author.should_receive(:search).with(:guid => subject.author_guid).and_return(records)
        subject.coauthor.should eq record
      end
    end

    context "specific association with class name and foreign_key" do
      let(:author_guid) { "AUT-456" }

      subject { Post.new(:bestseller_guid => author_guid) }
      it { should respond_to(:bestseller) }

      it "searches the associated model for a single record" do
        Author.should_receive(:search).with(:guid => subject.bestseller_guid).and_return(records)
        subject.bestseller.should eq record
      end
    end
  end

  describe ".has_many" do
    let(:records) { [ record, record, record ] }
    let(:guid) { "AUT-123" }
    let(:user_guid) { "USR-123" }

    subject { Author.new(:guid => guid, :user_guid => user_guid) }

    it { should respond_to(:posts) }

    it "searches the associated model for all associated records" do
      Post.should_receive(:search).with(:author_guid => subject.guid).and_return(records)
      subject.posts.should eq records
    end

    it "memoizes the result record" do
      Post.should_receive(:search).once.with(:author_guid => subject.guid).and_return(records)
      3.times { subject.posts.should eq records }
    end

    context "when guid is nil" do
      subject { Author.new }

      it "returns []" do
        subject.posts.should eq []
      end
    end

    context "when the search is empty" do
      it "returns the empty set" do
        Post.should_receive(:search).with(:author_guid => subject.guid).and_return([])
        subject.posts.should be_empty
      end
    end

    context "specific association with class name" do
      it { should respond_to(:flagged_posts) }

      it "searches the associated model for a single record" do
        Post.should_receive(:search).with(:author_guid => subject.guid).and_return([])
        subject.flagged_posts.should be_empty
      end
    end

    context "specific association with class name and foreign_key" do
      it { should respond_to(:bestseller_posts) }

      it "searches the associated model for multiple record" do
        Post.should_receive(:search).with(:bestseller_guid => subject.guid).and_return(records)
        subject.bestseller_posts.should eq(records)
      end
    end

    context 'scoped field' do
      it { should respond_to(:user_posts) }

      it "searches the associated model for multiple records" do
        Post.should_receive(:search).with(:author_guid => subject.guid, :user_guid => subject.user_guid).and_return(records)
        subject.user_posts.should eq(records)
      end

      context 'when user_guid doesnt exist on model 'do
        before { subject.stub(:respond_to?).with("user_guid").and_return(false) }

        it 'raises an error' do
          expect {subject.user_posts}.to raise_error
        end
      end

      context 'when user_guid doesnt exist on associated model 'do
        before { Post.stub_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

        it 'raises an error' do
          expect {subject.user_posts}.to raise_error
        end
      end
    end
  end

  describe ".has_one" do
    let(:guid) { "PST-123" }
    let(:user_guid) { "USR-123" }

    subject { Post.new(:guid => guid, :user_guid => user_guid) }

    it { should respond_to(:category) }

    it "searches the associated model for all associated records" do
      Category.should_receive(:search).with(:post_guid => subject.guid).and_return(records)
      subject.category.should eq record
    end

    it "memoizes the result record" do
      Category.should_receive(:search).once.with(:post_guid => subject.guid).and_return(records)
      3.times { subject.category.should eq record }
    end

    context "when guid is nil" do
      subject { Post.new }

      it "returns nil" do
        subject.category.should be_nil
      end
    end

    context "when the search is empty" do
      it "returns a nil value" do
        Category.should_receive(:search).with(:post_guid => subject.guid).and_return([])
        subject.category.should be_nil
      end
    end

    context "specific association with class name" do
      it { should respond_to(:main_category) }

      it "searches the associated model for a single record" do
        Category.should_receive(:search).with(:post_guid => subject.guid).and_return(records)
        subject.main_category.should eq record
      end
    end

    context "specific association with class name and foreign_key" do
      it { should respond_to(:default_category) }

      it "searches the associated model for a single record" do
        Category.should_receive(:search).with(:template_post_guid => subject.guid).and_return(records)
        subject.default_category.should eq record
      end
    end

    context 'scoped field' do
      it { should respond_to(:hidden_category) }

      it "searches the associated model for multiple records" do
        Category.should_receive(:search).with(:post_guid => subject.guid, :user_guid => subject.user_guid).and_return(records)
        subject.hidden_category.should eq(record)
      end

      context 'when user_guid doesnt exist on model 'do
        before { subject.stub(:respond_to?).with("user_guid").and_return(false) }

        it 'raises an error' do
          expect {subject.hidden_category}.to raise_error
        end
      end

      context 'when user_guid doesnt exist on associated model 'do
        before { Category.stub_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

        it 'raises an error' do
          expect {subject.hidden_category}.to raise_error
        end
      end
    end
  end
end
