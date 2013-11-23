require 'spec_helper'

describe ::ActiveRemote::Integration do
  let(:guid) { "GUID-derp" }
  subject { Tag.new(:guid => guid) }

  context "#to_param" do
    # API
    specify { subject.should respond_to(:to_param) }

    it "returns the guid if the guid is present (by default)" do
      subject.to_param.should eq(guid)
    end
  end

  context "#cache_key" do
    # API
    specify { subject.should respond_to(:cache_key) }

    it "sets 'new' as the identifier when the record has not been persisted" do
      subject.should_receive(:new_record?).and_return(true)
      subject.cache_key.should match(/tag\/new/)
    end

    it "sets the cache_key to the class/guid as a default" do
      subject.should_receive(:new_record?).and_return(false)
      subject.cache_key.should eq("tag/#{guid}")
    end

  end
end
