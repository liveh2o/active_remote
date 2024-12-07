require "spec_helper"

RSpec.describe ActiveRemote::Serialization do
  describe ".serialize_records" do
    let(:records) { [{foo: "bar"}] }

    subject { Tag.new }

    it "serializes records into active remote objects" do
      Tag.serialize_records(records).each do |record|
        expect(record).to be_a Tag
      end
    end
  end

  describe "#add_errors" do
    let(:error) { Generic::Error.new(field: "name", message: "Boom!") }
    let(:response) {
      tag = Generic::Remote::Tag.new
      tag.errors << error
      tag
    }

    subject { Tag.new }

    context "when the response has errors" do
      it "adds the errors to the active remote object" do
        subject.add_errors(response.errors)
        expect(subject.errors[:name]).to match_array(["Boom!"])
      end
    end
  end
end
