require 'spec_helper'

describe ActiveRemote::Serialization do
  describe "#serialize_records" do
    context "when the last response has records" do
      it "serializes protobuf objects into active remote objects"
    end

    context "when the last response doesn't respond to records" do
      it "returns nil"
    end
  end
end