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

    it "is false when the attribute is 0.0" do
      subject.name = 0.0
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is 0.1" do
      subject.name = 0.1
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is a zero BigDecimal" do
      subject.name = BigDecimal.new("0.0")
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is a non-zero BigDecimal" do
      subject.name = BigDecimal.new("0.1")
      expect(subject.name?).to eq true
    end

    it "is true when the attribute is -1" do
      subject.name = -1
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is -0.0" do
      subject.name = -0.0
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is -0.1" do
      subject.name = -0.1
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is a negative zero BigDecimal" do
      subject.name = BigDecimal.new("-0.0")
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is a negative BigDecimal" do
      subject.name = BigDecimal.new("-0.1")
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is '0'" do
      subject.name = "0"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is '1'" do
      subject.name = "1"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is '0.0'" do
      subject.name = "0.0"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is '0.1'" do
      subject.name = "0.1"
      expect(subject.name?).to eq true
    end

    it "is true when the attribute is '-1'" do
      subject.name = "-1"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is '-0.0'" do
      subject.name = "-0.0"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is '-0.1'" do
      subject.name = "-0.1"
      expect(subject.name?).to eq true
    end

    it "is true when the attribute is 'true'" do
      subject.name = "true"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is 'false'" do
      subject.name = "false"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is 't'" do
      subject.name = "t"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is 'f'" do
      subject.name = "f"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is 'T'" do
      subject.name = "T"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is 'F'" do
      subject.name = "F"
      expect(subject.name?).to eq false
    end

    it "is true when the attribute is 'TRUE'" do
      subject.name = "TRUE"
      expect(subject.name?).to eq true
    end

    it "is false when the attribute is 'FALSE" do
      subject.name = "FALSE"
      expect(subject.name?).to eq false
    end
  end
end
