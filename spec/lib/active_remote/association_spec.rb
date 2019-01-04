require "spec_helper"

describe ActiveRemote::Association do
  let(:record) { double(:record) }
  let(:records) { [record] }

  describe ".belongs_to" do
    context "simple association" do
      let(:author_guid) { "AUT-123" }
      let(:user_guid) { "USR-123" }
      let(:default_category_guid) { "CAT-123" }
      subject { Post.new(:author_guid => author_guid, :user_guid => user_guid) }

      it { is_expected.to respond_to(:author) }
      it { is_expected.to respond_to(:author=) }

      it "searches the associated model for a single record" do
        expect(Author).to receive(:search).with(:guid => subject.author_guid).and_return(records)
        expect(subject.author).to eq record
      end

      it "memoizes the result record" do
        expect(Author).to receive(:search).once.with(:guid => subject.author_guid).and_return(records)
        3.times { expect(subject.author).to eq record }
      end

      context "when guid is nil" do
        subject { Post.new }

        it "returns nil" do
          expect(subject.author).to be_nil
        end
      end

      context "when the search is empty" do
        it "returns a nil" do
          expect(Author).to receive(:search).with(:guid => subject.author_guid).and_return([])
          expect(subject.author).to be_nil
        end
      end

      context "scoped field" do
        it { is_expected.to respond_to(:user) }

        it "searches the associated model for multiple records" do
          expect(Author).to receive(:search).with(:guid => subject.author_guid, :user_guid => subject.user_guid).and_return(records)
          expect(subject.user).to eq(record)
        end

        context "when user_guid doesnt exist on model " do
          before { allow(subject.class).to receive_message_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

          it "raises an error" do
            expect { subject.user }.to raise_error(::RuntimeError, /Could not find attribute/)
          end
        end

        context "when user_guid doesnt exist on associated model " do
          before { allow(Author).to receive_message_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

          it "raises an error" do
            expect { subject.user }.to raise_error(::RuntimeError, /Could not find attribute/)
          end
        end
      end
    end

    context "specific association with class name" do
      let(:author_guid) { "AUT-456" }

      subject { Post.new(:author_guid => author_guid) }
      it { is_expected.to respond_to(:coauthor) }

      it "searches the associated model for a single record" do
        expect(Author).to receive(:search).with(:guid => subject.author_guid).and_return(records)
        expect(subject.coauthor).to eq record
      end

      it "should create a setter method" do
        expect(subject).to respond_to(:coauthor=)
      end
    end

    context "specific association with class name and foreign_key" do
      let(:author_guid) { "AUT-456" }

      subject { Post.new(:bestseller_guid => author_guid) }
      it { is_expected.to respond_to(:bestseller) }

      it "searches the associated model for a single record" do
        expect(Author).to receive(:search).with(:guid => subject.bestseller_guid).and_return(records)
        expect(subject.bestseller).to eq record
      end
    end
  end

  describe ".has_many" do
    let(:records) { [record, record, record] }
    let(:guid) { "AUT-123" }
    let(:user_guid) { "USR-123" }

    subject { Author.new(:guid => guid, :user_guid => user_guid) }

    it { is_expected.to respond_to(:posts) }
    it { is_expected.to respond_to(:posts=) }

    it "searches the associated model for all associated records" do
      expect(Post).to receive(:search).with(:author_guid => subject.guid).and_return(records)
      expect(subject.posts).to eq records
    end

    it "memoizes the result record" do
      expect(Post).to receive(:search).once.with(:author_guid => subject.guid).and_return(records)
      3.times { expect(subject.posts).to eq records }
    end

    context "when guid is nil" do
      subject { Author.new }

      it "returns []" do
        expect(subject.posts).to eq []
      end
    end

    context "when the search is empty" do
      it "returns the empty set" do
        expect(Post).to receive(:search).with(:author_guid => subject.guid).and_return([])
        expect(subject.posts).to be_empty
      end
    end

    context "specific association with class name" do
      it { is_expected.to respond_to(:flagged_posts) }

      it "searches the associated model for a single record" do
        expect(Post).to receive(:search).with(:author_guid => subject.guid).and_return([])
        expect(subject.flagged_posts).to be_empty
      end
    end

    context "specific association with class name and foreign_key" do
      it { is_expected.to respond_to(:bestseller_posts) }

      it "searches the associated model for multiple record" do
        expect(Post).to receive(:search).with(:bestseller_guid => subject.guid).and_return(records)
        expect(subject.bestseller_posts).to eq(records)
      end
    end

    context "scoped field" do
      it { is_expected.to respond_to(:user_posts) }

      it "searches the associated model for multiple records" do
        expect(Post).to receive(:search).with(:author_guid => subject.guid, :user_guid => subject.user_guid).and_return(records)
        expect(subject.user_posts).to eq(records)
      end

      context "when user_guid doesnt exist on associated model " do
        before { allow(Post).to receive_message_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

        it "raises an error" do
          expect { subject.user_posts }.to raise_error(::RuntimeError, /Could not find attribute/)
        end
      end
    end

    context "writer method" do
      context "when new value is not an array" do
        it "should raise error" do
          expect { subject.posts = Post.new }.to raise_error(::RuntimeError, /New value must be an array/)
        end
      end
    end
  end

  describe ".has_one" do
    let(:guid) { "CAT-123" }
    let(:user_guid) { "USR-123" }
    let(:category_attributes) {
      {
        :guid => guid,
        :user_guid => user_guid
      }
    }

    subject { Category.new(category_attributes) }

    it { is_expected.to respond_to(:author) }
    it { is_expected.to respond_to(:author=) }

    it "searches the associated model for all associated records" do
      expect(Author).to receive(:search).with(:category_guid => subject.guid).and_return(records)
      expect(subject.author).to eq record
    end

    it "memoizes the result record" do
      expect(Author).to receive(:search).once.with(:category_guid => subject.guid).and_return(records)
      3.times { expect(subject.author).to eq record }
    end

    context "when guid is nil" do
      subject { Category.new }

      it "returns nil" do
        expect(subject.author).to be_nil
      end
    end

    context "when the search is empty" do
      it "returns a nil value" do
        expect(Author).to receive(:search).with(:category_guid => subject.guid).and_return([])
        expect(subject.author).to be_nil
      end
    end

    context "specific association with class name" do
      it { is_expected.to respond_to(:senior_author) }

      it "searches the associated model for a single record" do
        expect(Author).to receive(:search).with(:category_guid => subject.guid).and_return(records)
        expect(subject.senior_author).to eq record
      end

      it "should create a setter method" do
        expect(subject).to respond_to(:senior_author=)
      end
    end

    context "specific association with class name and foreign_key" do
      it { is_expected.to respond_to(:primary_editor) }

      it "searches the associated model for a single record" do
        expect(Author).to receive(:search).with(:editor_guid => subject.guid).and_return(records)
        expect(subject.primary_editor).to eq record
      end
    end

    context "scoped field" do
      it { is_expected.to respond_to(:chief_editor) }

      it "searches the associated model for multiple records" do
        expect(Author).to receive(:search).with(:chief_editor_guid => subject.guid, :user_guid => subject.user_guid).and_return(records)
        expect(subject.chief_editor).to eq(record)
      end

      context "when user_guid doesnt exist on associated model " do
        before { allow(Author).to receive_message_chain(:public_instance_methods, :include?).with(:user_guid).and_return(false) }

        it "raises an error" do
          expect { subject.chief_editor }.to raise_error(::RuntimeError, /Could not find attribute/)
        end
      end
    end
  end
end
