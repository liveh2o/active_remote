require 'spec_helper'

describe ActiveRemote::Bulk do
  let(:records) { double(:records, :to_hash => {}) }
  let(:serialized_records) { double(:serialized_records) }

  describe ".create_all" do
    before { Tag.better_stub(:parse_records).and_return(records) }

    it "creates remote records" do
      Tag.any_instance.better_receive(:execute).with(:create_all, records)
      Tag.create_all(records)
    end
  end

  describe ".delete_all" do
    before { Tag.better_stub(:parse_records).and_return(records) }

    it "deletes remote records" do
      Tag.any_instance.better_receive(:execute).with(:delete_all, records)
      Tag.delete_all(records)
    end
  end

  describe ".destroy_all" do
    before { Tag.better_stub(:parse_records).and_return(records) }

    it "destroys remote records" do
      Tag.any_instance.better_receive(:execute).with(:destroy_all, records)
      Tag.destroy_all(records)
    end
  end

  describe ".parse_records" do
    let(:records) { [ Hash.new ] }
    let(:empty_records) { [] }
    let(:attribute_record) {
      record = double(Hash)
      record.stub(:attributes) { {} }
      record
    }

    it "returns an empty array when given empty records" do
      parsed_records = { :records => [] }
      Tag.parse_records(empty_records).should eq(parsed_records)
    end

    it "preps records to be built into a bulk request" do
      parsed_records = { :records => records }
      Tag.parse_records(records).should eq parsed_records
    end

    it "preps records to be built into a bulk request (prioritizing :attributes over :to_hash)" do
      attribute_record.should_receive(:attributes)
      parsed_records = { :records => [ {} ] }
      Tag.parse_records([ attribute_record ]).should eq parsed_records
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
    before { Tag.stub(:parse_records).and_return(records) }

    it "updates remote records" do
      Tag.any_instance.better_receive(:execute).with(:update_all, records)
      Tag.update_all(records)
    end
  end
end
