require 'spec_helper'

describe ActiveRemote::Persistence do
  let(:message) do
    double(:protos, :fields => [ double(:field, :name => :records, :repeated? => true) ], :records => [])
  end

  describe ".create_all" do
    xit "creates remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:create_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.create_all(records)
    end
  end

  describe ".create_all!" do
    xit "creates remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:create_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.create_all(records)
    end

    context "when any remote records have errors" do
      it "raises an exception"
    end
  end

  describe ".delete_all" do
    xit "deletes remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:delete_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.delete_all(records)
    end
  end

  describe ".delete_all!" do
    xit "deletes remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:delete_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.delete_all(records)
    end

    context "when any remote records have errors" do
      it "raises an exception"
    end
  end

  describe ".destroy_all" do
    it "destroys remote records"
  end

  describe ".destroy_all!" do
    it "destroy remote records"

    context "when any remote records have errors" do
      it "raises an exception"
    end
  end

  describe ".parse_records" do
    it "preps records to be built into a bulk request"
  end

  describe ".update_all" do
    xit "updates remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:update_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.update_all(records)
    end
  end

  describe ".update_all!" do
    xit "updates remote records" do
      records = []
      described_class.any_instance.should_receive(:_execute).with(:update_all, records, :bulk => true)
      described_class.any_instance.stub(:last_response).and_return(message)
      described_class.update_all(records)
    end

    context "when any remote records have errors" do
      it "raises an exception"
    end
  end

  describe ".create" do
    it "initializes and saves a new record"

    context "when the record has errors" do
      it "returns an unsaved record"
    end
  end

  describe ".create!" do
    it "initializes and saves a new record"

    context "when the record has errors" do
      it "raises an exception"
    end
  end

  describe "#assign_attributes" do
    it "updates attributes with the given hash"
  end

  describe "#delete" do
    xit "deletes a remote record" do
      subject.should_receive(:_execute).with(:delete, subject.attributes)
      subject.delete
    end
  end

  describe "#delete!" do
    xit "deletes a remote record" do
      subject.should_receive(:_execute).with(:delete, subject.attributes)
      subject.delete
    end

    context "when an error occurs" do
      it "raises an exception"
    end
  end

  describe "#destroy" do
    xit "destroys a remote record" do
      subject.should_receive(:_execute).with(:destroy, subject.attributes)
      subject.destroy
    end
  end

  describe "#destroy!" do
    xit "destroys a remote record" do
      subject.should_receive(:_execute).with(:destroy, subject.attributes)
      subject.destroy
    end

    context "when an error occurs" do
      it "raises an exception"
    end
  end

  describe "#has_errors?" do
    context "when errors are not present" do
      # its(:has_errors?) { should be_false }
    end

    context "when errors are present" do
      # its(:has_errors?) { should be_true }
    end
  end

  describe "#new_record?" do
    context "when the record is persisted" do
      # its(:new_record?) { should be_false }
    end

    context "when the record is not persisted" do
      # its(:new_record?) { should be_true }
    end
  end

  describe "#persisted?" do
    context "when the record has a guid" do
      # its(:persisted?) { should be_true }
    end

    context "when the record does not have a guid" do
      # its(:persisted?) { should be_false }
    end
  end

  describe "#save" do
    it "runs callbacks"

    context "when the record is persisted" do
      it "updates the record"
    end

    context "when the record is not persisted" do
      it "creates the record"
    end

    context "when the record is saved" do
      it "returns true"
    end

    context "when the record is not saved" do
      it "returns false"
    end
  end

  describe "#save!" do
    it "saves the record"

    context "when the record is saved" do
      it "returns true"
    end

    context "when the record is not saved" do
      it "raises an exception"
    end
  end

  describe "#success?" do
    context "when errors are present" do
      # its(:success?) { should be_false }
    end

    context "when errors are not present" do
      # its(:success?) { should be_true }
    end
  end

  describe "#update_attributes" do
    it "assigns new attributes"
    it "saves the record"
  end

  describe "#update_attributes!" do
    it "assigns new attributes"
    it "saves! the record"
  end
end
