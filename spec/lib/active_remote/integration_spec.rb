require "spec_helper"

describe ::ActiveRemote::Integration do
  let(:guid) { "GUID-derp" }
  let(:tag) { ::Tag.new(:guid => guid) }

  subject { tag }

  context ".to_param" do
    specify { expect(::Tag).to respond_to(:to_param) }
  end

  context "#to_param" do
    specify { expect(subject).to respond_to(:to_param) }

    it "returns the guid if the guid is present (by default)" do
      expect(tag.to_param).to eq(guid)
    end
  end

  context "#cache_key" do
    specify { expect(subject).to respond_to(:cache_key) }

    it "sets 'new' as the identifier when the record has not been persisted" do
      expect(tag).to receive(:new_record?).and_return(true)
      expect(tag.cache_key).to match(/tags\/new/)
    end

    it "sets the cache_key to the class/guid as a default" do
      expect(tag).to receive(:new_record?).and_return(false)
      expect(tag.cache_key).to eq("tags/#{guid}")
    end

    it "adds the 'updated_at' attribute to the cache_key if updated_at is present" do
      ::ActiveRemote.config.default_cache_key_updated_at = true
      twenty_o_one_one = tag.updated_at = DateTime.new(2001, 0o1, 0o1)
      expect(tag).to receive(:new_record?).and_return(false)
      expect(tag.cache_key).to eq("tags/#{guid}-#{twenty_o_one_one.to_fs(:usec)}")
      tag.updated_at = nil
      ::ActiveRemote.config.default_cache_key_updated_at = false
    end

    it "defaults the cache updated_at to false" do
      expect(::ActiveRemote.config.default_cache_key_updated_at?).to be_falsey
    end
  end

  describe "#cache_key_with_version" do
    let(:tag) { ::Tag.new(:guid => guid, :updated_at => ::DateTime.current) }

    specify { expect(subject).to respond_to(:cache_key_with_version) }

    context "when cache versioning is enabled" do
      around do |example|
        cache_versioning_value = ::Tag.cache_versioning
        ::Tag.cache_versioning = true
        example.run
        ::Tag.cache_versioning = cache_versioning_value
      end

      it "returns a cache key with the version" do
        expect(tag.cache_version).to be_present
        expect(tag.cache_key_with_version).to eq("#{tag.cache_key}-#{tag.cache_version}")
      end
    end

    context "when cache versioning is not enabled" do
      around do |example|
        cache_versioning_value = ::Tag.cache_versioning
        ::Tag.cache_versioning = false
        example.run
        ::Tag.cache_versioning = cache_versioning_value
      end

      it "returns a cache key without the version" do
        expect(tag.cache_key_with_version).to eq(tag.cache_key)
      end
    end
  end

  describe "#cache_version" do
    specify { expect(subject).to respond_to(:cache_version) }

    context "when cache versioning is enabled" do
      around do |example|
        cache_versioning_value = ::Tag.cache_versioning
        ::Tag.cache_versioning = true
        example.run
        ::Tag.cache_versioning = cache_versioning_value
      end

      it "returns a cache version" do
        tag.updated_at = DateTime.new(2001, 0o1, 0o1)
        expect(tag.cache_version).to eq(tag.updated_at.utc.to_fs(:usec))
      end
    end

    context "when cache versioning is not enabled" do
      around do |example|
        cache_versioning_value = ::Tag.cache_versioning
        ::Tag.cache_versioning = false
        example.run
        ::Tag.cache_versioning = cache_versioning_value
      end

      it "returns nil" do
        expect(tag.cache_version).to be_nil
      end
    end
  end
end
