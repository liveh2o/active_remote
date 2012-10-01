require 'spec_helper'

describe ActiveRemote::Bulk do
  let(:records) { double(:records, :to_hash => {}) }
  let(:serialized_records) { double(:serialized_records) }

  describe ".create_all" do
    before {
      Tag.stub(:parse_records).and_return(records)
      Tag.any_instance.stub(:serialize_records).and_return(serialized_records)
    }

    it "creates remote records" do
      Tag.any_instance.should_receive(:execute).with(:create_all, records)
      Tag.create_all(records)
    end
  end

  describe ".delete_all" do
    before {
      Tag.stub(:parse_records).and_return(records)
      Tag.any_instance.stub(:serialize_records).and_return(serialized_records)
    }

    it "deletes remote records" do
      Tag.any_instance.should_receive(:execute).with(:delete_all, records)
      Tag.delete_all(records)
    end
  end

  describe ".destroy_all" do
    before {
      Tag.stub(:parse_records).and_return(records)
      Tag.any_instance.stub(:serialize_records).and_return(serialized_records)
    }

    it "destroys remote records" do
      Tag.any_instance.should_receive(:execute).with(:destroy_all, records)
      Tag.destroy_all(records)
    end
  end

  describe ".parse_records" do
    let(:records) { [ Hash.new ] }

    it "preps records to be built into a bulk request" do
      parsed_records = { :records => records }
      Tag.parse_records(records).should eq parsed_records
    end

    context "when given a bulk message" do
      let(:records) { [ tag.to_hash ] }
      let(:tag) { Generic::Remote::Tag.new }
      let(:tags) { Generic::Remote::Tags.new(:records => [ tag ]) }

      it "preps records to be built into a bulk request" do
        parsed_records = { :records => records }
        Tag.parse_records(tags).should eq parsed_records
      end
    end
  end

  describe ".update_all" do
    before {
      Tag.stub(:parse_records).and_return(records)
      Tag.any_instance.stub(:serialize_records).and_return(serialized_records)
    }

    it "updates remote records" do
      Tag.any_instance.should_receive(:execute).with(:update_all, records)
      Tag.update_all(records)
    end
  end
end