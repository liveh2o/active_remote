require 'spec_helper'

describe ::ActiveRemote::Persistence do
  let(:response_without_errors) { ::HashWithIndifferentAccess.new(:errors => []) }
  let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class) }

  subject { ::Tag.new }

  before {
    allow(rpc).to receive(:execute).and_return(response_without_errors)
    allow(Tag).to receive(:rpc).and_return(rpc)
  }
  after { allow(::Tag).to receive(:rpc).and_call_original }

  describe ".create" do
    it "runs create callbacks" do
      expect_any_instance_of(Tag).to receive(:after_create_callback)
      Tag.create(:name => 'foo')
    end

    it "initializes and saves a new record" do
      expect_any_instance_of(Tag).to receive(:save)
      Tag.create(:name => 'foo')
    end

    it "returns a new record" do
      value = Tag.create(:name => 'foo')
      expect(value).to be_a(Tag)
    end

    context "when the server state changes" do
      let(:response_without_errors) { ::HashWithIndifferentAccess.new(:errors => [], :user_guid => "123") }

      it "uses the server state on create" do
        tag = Tag.create({:name => "Ron", :user_guid => "456"})
        expect(tag.name).to eq(nil)
        expect(tag.user_guid).to eq("123")
      end
    end
  end

  describe ".create!" do
    it "initializes and saves a new record" do
      expect_any_instance_of(Tag).to receive(:save!)
      Tag.create!(:name => 'foo')
    end

    context "when the record has errors" do
      before { allow_any_instance_of(Tag).to receive(:save!).and_raise(ActiveRemote::ActiveRemoteError) }

      it "raises an exception" do
        expect { Tag.create!(:name => 'foo') }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#delete" do
    it "deletes a remote record" do
      expect(rpc).to receive(:execute).with(:delete, subject.scope_key_hash)
      subject.delete
    end

    context "when the record doesn't have errors" do
      it "freezes the record" do
        subject.delete
        expect(subject.frozen?).to be_truthy
      end
    end

    context "when the response has errors" do
      let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
      let(:response) { Generic::Remote::Tag.new(:errors => [ error ]) }

      before { allow(rpc).to receive(:execute).and_return(response) }

      it "adds the errors to the record" do
        subject.delete
        expect(subject.has_errors?).to be_truthy
      end

      it "returns false" do
        expect(subject.delete).to be_falsey
      end
    end
  end

  describe "#delete!" do
    it "deletes a remote record" do
      expect(rpc).to receive(:execute).with(:delete, subject.scope_key_hash)
      subject.delete!
    end

    context "when an error occurs" do
      let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
      let(:response) { Generic::Remote::Tag.new(:errors => [ error ]) }

      before { allow(rpc).to receive(:execute).and_return(response) }

      it "raises an exception" do
        expect { subject.delete! }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#destroy" do
    it "destroys a remote record" do
      expect(rpc).to receive(:execute).with(:destroy, subject.scope_key_hash)
      subject.destroy
    end

    context "when the record doesn't have errors" do
      it "freezes the record" do
        subject.destroy
        expect(subject.frozen?).to be_truthy
      end
    end

    context "when the response has errors" do
      let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
      let(:response) { Generic::Remote::Tag.new(:errors => [ error ]) }

      before { allow(rpc).to receive(:execute).and_return(response) }

      it "adds the errors to the record" do
        subject.destroy
        expect(subject.has_errors?).to be_truthy
      end

      it "returns false" do
        expect(subject.destroy).to be_falsey
      end
    end
  end

  describe "#destroy!" do
    it "destroys a remote record" do
      expect(rpc).to receive(:execute).with(:destroy, subject.scope_key_hash)
      subject.destroy!
    end

    context "when an error occurs" do
      let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
      let(:response) { Generic::Remote::Tag.new(:errors => [ error ]) }

      before { allow(rpc).to receive(:execute).and_return(response) }

      it "raises an exception" do
        expect { subject.destroy! }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end

  describe "#readonly?" do
    context "when the record is created through instantiate with options[:readonly]" do
      subject { Tag.instantiate({:guid => 'foo'}, :readonly => true) }

      its(:new_record?) { should be_falsey }
      its(:readonly?) { should be_truthy }
    end
  end

  describe "#has_errors?" do
    context "when errors are not present" do
      before { subject.errors.clear }

      its(:has_errors?) { should be_falsey }
    end

    context "when errors are present" do
      before { subject.errors[:base] << "Boom!" }

      its(:has_errors?) { should be_truthy }
    end
  end

  describe "#new_record?" do
    context "when the record is created through instantiate" do
      subject { Tag.instantiate(:guid => 'foo') }

      its(:new_record?) { should be_falsey }
    end

    context "when the record is persisted" do
      subject { Tag.allocate.instantiate(:guid => 'foo') }

      its(:new_record?) { should be_falsey }
    end

    context "when the record is not persisted" do
      subject { Tag.new }

      its(:new_record?) { should be_truthy }
    end
  end

  describe "#persisted?" do
    context "when the record is persisted" do
      subject { Tag.allocate.instantiate(:guid => 'foo') }

      its(:persisted?) { should be_truthy }
    end

    context "when the record is not persisted" do
      subject { Tag.new }

      its(:persisted?) { should be_falsey }
    end
  end

  describe "#save" do
    it "runs save callbacks" do
      allow(subject).to receive(:run_callbacks).with(:validation).and_return(true)
      expect(subject).to receive(:run_callbacks).with(:save)
      subject.save
    end

    context "when the record is new" do
      subject { Tag.new }

      it "creates the record" do
        expected_attributes = subject.attributes
        expect(rpc).to receive(:execute).with(:create, expected_attributes)
        subject.save
      end
    end

    context "when the record is not new" do
      let(:attributes) { { 'guid' => 'foo' } }

      subject { Tag.allocate.instantiate(attributes) }

      it "updates the record" do
        expect(rpc).to receive(:execute).with(:update, attributes)
        subject.save
      end
    end

    context "when the record is saved" do
      it "returns true" do
        allow(subject).to receive(:has_errors?) { false }
        expect(subject.save).to be_truthy
      end
    end

    context "when the record is not saved" do
      it "returns false" do
        allow(subject).to receive(:has_errors?) { true }
        expect(subject.save).to be_falsey
      end
    end

    context "when the record has errors before the save" do
      before { subject.errors[:base] << "Boom!" }

      it "clears the errors before the save" do
        expect(subject.errors).not_to be_empty
        expect(subject.save).to be_truthy
        expect(subject.errors).to be_empty
      end
    end
  end

  describe "#save!" do
    context "when the record is saved" do
      it "returns true" do
        allow(subject).to receive(:save).and_return(true)
        expect(subject.save!).to be_truthy
      end
    end

    context "when the record is not saved" do
      it "raises an exception" do
        allow(subject).to receive(:save).and_return(false)
        expect { subject.save! }.to raise_error(ActiveRemote::RemoteRecordNotSaved)
      end
    end
  end

  describe "#success?" do
    context "when errors are present" do
      before { subject.errors[:base] << "Boom!" }

      its(:success?) { should be_falsey }
    end

    context "when errors are not present" do
      before { subject.errors.clear }

      its(:success?) { should be_truthy }
    end
  end

  describe "#update_attribute" do
    let(:tag) { Tag.allocate.instantiate({:guid => "123"}) }

    it "runs update callbacks" do
      expect(tag).to receive(:after_update_callback)
      tag.update_attribute(:name, "foo")
    end

    it "updates a remote record" do
      expect(rpc).to receive(:execute).with(:update, {"name" => "foo", "guid" => "123"})
      tag.update_attribute(:name, "foo")
    end

    before { allow(subject).to receive(:save) }
    after { allow(subject).to receive(:save).and_call_original }

    it "assigns new attributes" do
      expect(subject).to receive(:name=).with("foo")
      subject.update_attribute(:name, "foo")
    end

    it "saves the record" do
      expect(subject).to receive(:save)
      subject.update_attribute(:name, "foo")
    end
  end

  describe "#update_attributes" do
    let(:attributes) { HashWithIndifferentAccess.new(:name => 'bar') }
    let(:tag) { Tag.allocate.instantiate({:guid => "123"}) }

    it "runs update callbacks" do
      expect(tag).to receive(:after_update_callback)
      tag.update_attributes({})
    end

    it "updates a remote record" do
      expect(rpc).to receive(:execute).with(:update, tag.scope_key_hash)
      tag.update_attributes({})
    end

    before { allow(subject).to receive(:save) }
    after { allow(subject).to receive(:save).and_call_original }

    it "assigns new attributes" do
      expect(subject).to receive(:assign_attributes).with(attributes)
      subject.update_attributes(attributes)
    end

    it "saves the record" do
      expect(subject).to receive(:save)
      subject.update_attributes(attributes)
    end

    context "when the server state changes" do
      let(:response_without_errors) { ::HashWithIndifferentAccess.new(:errors => [], :user_guid => "123") }

      it "uses the server state on update" do
        tag.update_attributes({:name => "Ron", :user_guid => "456"})
        expect(tag.name).to eq(nil)
        expect(tag.user_guid).to eq("123")
      end
    end
  end

  describe "#update_attributes!" do
    let(:attributes) { HashWithIndifferentAccess.new(:name => 'bar') }

    before { allow(subject).to receive(:save!) }
    after { allow(subject).to receive(:save!).and_call_original }

    it "assigns new attributes" do
      expect(subject).to receive(:assign_attributes).with(attributes)
      subject.update_attributes!(attributes)
    end

    it "saves! the record" do
      expect(subject).to receive(:save!)
      subject.update_attributes!(attributes)
    end
  end
end
