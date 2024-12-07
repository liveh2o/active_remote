require "spec_helper"

RSpec.describe ::ActiveRemote::QueryAttributes do
  subject { ::Author.new }

  describe "#query_attribute" do
    it "is false when the attribute is false" do
      subject.writes_fiction = false
      expect(subject.writes_fiction?).to eq false
    end

    it "is true when the attribute is true" do
      subject.writes_fiction = true
      expect(subject.writes_fiction?).to eq true
    end

    it "is false when the attribute is nil" do
      subject.name = nil
      expect(subject.name?).to eq false
    end

    it "is false when the attribute is an empty string" do
      subject.name = ""
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is a non-empty string" do
      subject.name = "Chris"
      expect(subject.name?).to eq true
    end

    # This behavior varies from ActiveRecord, so we test it explicitly
    it "is true when the attribute is 0" do
      subject.age = 0
      expect(subject.age?).to eq true
    end

    it "is true when the attribute is 1" do
      subject.age = 1
      expect(subject.age?).to eq true
    end
  end
end
