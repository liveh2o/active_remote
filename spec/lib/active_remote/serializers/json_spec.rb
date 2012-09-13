require 'spec_helper'

describe ActiveRemote::Serializers::JSON do
  describe "#as_json" do
    context "with publishable attributes defined" do
      it "serializes to JSON with only the publishable attributes"
    end

    context "without publishable attributes defined" do
      it "serializes to JSON"
    end
  end
end
