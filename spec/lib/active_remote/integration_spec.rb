require "spec_helper"

describe ::ActiveRemote::Integration do
  let(:guid) { "GUID-derp" }
  subject { Tag.new(:guid => guid) }

  context "#to_param" do
    # API
    specify { expect(subject).to respond_to(:to_param) }

    it "returns the guid if the guid is present (by default)" do
      expect(subject.to_param).to eq(guid)
    end
  end

  context "#cache_key" do
    # API
    specify { expect(subject).to respond_to(:cache_key) }

    it "sets 'new' as the identifier when the record has not been persisted" do
      expect(subject).to receive(:new_record?).and_return(true)
      expect(subject.cache_key).to match(/tag\/new/)
    end

    it "sets the cache_key to the class/guid as a default" do
      expect(subject).to receive(:new_record?).and_return(false)
      expect(subject.cache_key).to eq("tag/#{guid}")
    end

    it "adds the 'updated_at' attribute to the cache_key if updated_at is present" do
      ::ActiveRemote.config.default_cache_key_updated_at = true
      twenty_o_one_one = subject[:updated_at] = DateTime.new(2001, 0o1, 0o1)
      expect(subject).to receive(:new_record?).and_return(false)
      expect(subject.cache_key).to eq("tag/#{guid}-#{twenty_o_one_one.to_s(:number)}")
      subject[:updated_at] = nil
      ::ActiveRemote.config.default_cache_key_updated_at = false
    end

    it "defaults the cache updated_at to false" do
      expect(::ActiveRemote.config.default_cache_key_updated_at?).to be_falsey
    end
  end
end
