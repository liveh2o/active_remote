require 'spec_helper'

describe ActiveRemote::Bulk do
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
end