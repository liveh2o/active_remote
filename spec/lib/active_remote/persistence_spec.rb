require 'spec_helper'

describe ActiveRemote::Persistence do
  subject { Tag.new }

  before { Tag.any_instance.stub(:last_response).and_return(HashWithIndifferentAccess.new) }

  describe ".create" do
    before { Tag.any_instance.stub(:execute) }
    after { Tag.any_instance.unstub(:execute) }

    it "initializes and saves a new record" do
      Tag.any_instance.should_receive(:save)
      Tag.create(:name => 'foo')
    end

    it "returns a new record" do
      value = Tag.create(:name => 'foo')
      value.should be_a(Tag)
    end
  end

  describe ".create!" do
    before { Tag.any_instance.stub(:execute) }
    after { Tag.any_instance.unstub(:execute) }

    it "initializes and saves a new record" do
      Tag.any_instance.should_receive(:save!)
      Tag.create!(:name => 'foo')
    end

    context "when the record has errors" do
      before { Tag.any_instance.stub(:save!).and_raise(ActiveRemote::ActiveRemoteError) }

      it "raises an exception" do
        expect { Tag.create!(:name => 'foo') }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#delete" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    it "deletes a remote record" do
      subject.should_receive(:execute).with(:delete, subject.attributes.slice("guid"))
      subject.delete
    end

    context "when the record doesn't have errors" do
      it "freezes the record" do
        subject.delete
        subject.frozen?.should be_true
      end
    end
  end

  describe "#delete!" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    it "deletes a remote record" do
      subject.should_receive(:execute).with(:delete, subject.attributes.slice("guid"))
      subject.delete!
    end

    context "when an error occurs" do
      before { subject.stub(:execute).and_raise(ActiveRemote::ActiveRemoteError) }

      it "raises an exception" do
        expect { subject.delete! }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#destroy" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    it "destroys a remote record" do
      subject.should_receive(:execute).with(:destroy, subject.attributes.slice("guid"))
      subject.destroy
    end

    context "when the record doesn't have errors" do
      it "freezes the record" do
        subject.destroy
        subject.frozen?.should be_true
      end
    end
  end

  describe "#destroy!" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    it "destroys a remote record" do
      subject.should_receive(:execute).with(:destroy, subject.attributes.slice("guid"))
      subject.destroy!
    end

    context "when an error occurs" do
      before { subject.stub(:execute).and_raise(ActiveRemote::ActiveRemoteError) }

      it "raises an exception" do
        expect { subject.destroy! }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#has_errors?" do
    context "when errors are not present" do
      before { subject.errors.clear }

      its(:has_errors?) { should be_false }
    end

    context "when errors are present" do
      before { subject.errors[:base] << "Boom!" }

      its(:has_errors?) { should be_true }
    end
  end

  describe "#new_record?" do
    context "when the record is persisted" do
      subject { Tag.new(:guid => 'foo') }

      its(:new_record?) { should be_false }
    end

    context "when the record is not persisted" do
      subject { Tag.new }

      its(:new_record?) { should be_true }
    end
  end

  describe "#persisted?" do
    context "when the record has a guid" do
      subject { Tag.new(:guid => 'foo') }

      its(:persisted?) { should be_true }
    end

    context "when the record does not have a guid" do
      subject { Tag.new }

      its(:persisted?) { should be_false }
    end
  end

  describe "#save" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    it "runs callbacks" do
      subject.should_receive(:run_callbacks).with(:save)
      subject.save
    end

    context "when the record is new" do
      subject { Tag.new }

      it "creates the record" do
        expected_attributes = subject.attributes.reject { |key, value| key == "guid" }
        subject.should_receive(:execute).with(:create, expected_attributes)
        subject.save
      end
    end

    context "when the record is not new" do
      let(:attributes) { { 'guid' => 'foo' } }

      subject { Tag.new(attributes) }

      it "updates the record" do
        subject.should_receive(:execute).with(:update, attributes)
        subject.save
      end
    end

    context "when the record is saved" do
      it "returns true" do
        subject.should_receive(:has_errors?) { false }
        subject.save.should be_true
      end
    end

    context "when the record is not saved" do
      it "returns false" do
        subject.should_receive(:has_errors?) { true }
        subject.save.should be_false
      end
    end

    context "when the record has errors before the save" do
      before { subject.errors[:base] << "Boom!" }

      it "clears the errors before the save" do
        subject.errors.should_not be_empty
        subject.save.should be_true
        subject.errors.should be_empty
      end
    end
  end

  describe "#save!" do
    before { subject.stub(:execute) }
    after { subject.unstub(:execute) }

    context "when the record is saved" do
      it "returns true" do
        subject.stub(:save).and_return(true)
        subject.save!.should be_true
      end
    end

    context "when the record is not saved" do
      it "raises an exception" do
        subject.stub(:save).and_return(false)
        expect { subject.save! }.to raise_error(ActiveRemote::RemoteRecordNotSaved)
      end
    end
  end

  describe "#success?" do
    context "when errors are present" do
      before { subject.errors[:base] << "Boom!" }

      its(:success?) { should be_false }
    end

    context "when errors are not present" do
      before { subject.errors.clear }

      its(:success?) { should be_true }
    end
  end

  describe "#update_attributes" do
    let(:attributes) { HashWithIndifferentAccess.new(:name => 'bar') }

    before { subject.stub(:save) }
    after { subject.unstub(:save) }

    it "assigns new attributes" do
      subject.should_receive(:assign_attributes).with(attributes)
      subject.update_attributes(attributes)
    end

    it "saves the record" do
      subject.should_receive(:save)
      subject.update_attributes(attributes)
    end
  end

  describe "#update_attributes!" do
    let(:attributes) { HashWithIndifferentAccess.new(:name => 'bar') }

    before { subject.stub(:save!) }
    after { subject.unstub(:save!) }

    it "assigns new attributes" do
      subject.should_receive(:assign_attributes).with(attributes)
      subject.update_attributes!(attributes)
    end

    it "saves! the record" do
      subject.should_receive(:save!)
      subject.update_attributes!(attributes)
    end
  end
end
