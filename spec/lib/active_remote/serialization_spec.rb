require 'spec_helper'

describe ActiveRemote::Serialization do
  describe "#serialize_records" do
    let(:last_response) {
      MessageWithOptions.new(:records => records)
    }
    let(:records) { [ { :foo => 'bar' } ] }

    subject { Tag.new }

    context "when the last response has records" do

      before { subject.stub(:last_response).and_return(last_response) }

      it "serializes records into active remote objects" do
        subject.serialize_records.each do |record|
          record.should be_a Tag
        end
      end
    end

    context "when the last response doesn't respond to records" do
      it "returns nil" do
        subject.serialize_records.should be_nil
      end
    end
  end
end
