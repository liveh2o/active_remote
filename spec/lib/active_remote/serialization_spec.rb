require 'spec_helper'

describe ActiveRemote::Serialization do
  describe ".serialize_records" do
    let(:records) { [ { :foo => 'bar' } ] }

    subject { Tag.new }

    it "serializes records into active remote objects" do
      Tag.serialize_records(records).each do |record|
        expect(record).to be_a Tag
      end
    end
  end

  describe "#add_errors" do
    let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
    let(:response) {
      tag = Generic::Remote::Tag.new
      tag.errors << error
      tag
    }

    subject { Tag.new }

    context "when the response has errors" do
      it "adds the errors to the active remote object" do
        subject.add_errors(response.errors)
        expect(subject.errors[:name]).to match_array(['Boom!'])
      end
    end
  end

  describe "#add_errors_from_response" do
    subject { Tag.new }

    context "when the response responds to :errors" do
      let(:error) { Generic::Error.new(:field => 'name', :message => 'Boom!') }
      let(:response) { Generic::Remote::Tag.new(:errors => [ error ]) }

      it "adds errors to the active remote object" do
        subject.better_receive(:add_errors).with(response.errors)
        subject.add_errors_from_response(response)
      end
    end

    context "when the response does not respond to :errors" do
      let(:response_without_errors) { double(:response_without_errors) }

      it "does not add errors" do
        subject.better_not_receive(:add_errors)
        subject.add_errors_from_response(response_without_errors)
      end
    end
  end
end
