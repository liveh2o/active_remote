require "spec_helper"

describe ::ActiveRemote::QueryAttributes do
  subject { ::Author.new }

  describe "#query_attribute" do
    it "raises when getting an undefined attribute" do
      expect { subject.query_attribute(:foobar) }.to raise_error(::ActiveRemote::UnknownAttributeError)
    end

    it "is false when the attribute is false" do
      subject.name = false
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is true" do
      subject.name = true
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is nil" do
      subject.name = nil
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is an Object" do
      subject.name = Object.new
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is an empty string" do
      subject.name = ""
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is a non-empty string" do
      subject.name = "Chris"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is 0" do
      subject.name = 0
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is 1" do
      subject.name = 1
      expect(subject.name?).to eq true
    end
  end
end
