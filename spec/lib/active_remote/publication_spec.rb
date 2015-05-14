require 'spec_helper'

describe ActiveRemote::Publication do
  let(:attributes) { { :guid => 'foo', :name => 'bar' } }

  subject { Tag.new(attributes) }

  context "with publishable attributes defined" do
    let(:expected_hash) { attributes.slice(:name) }

    before { Tag.attr_publishable :name }
    after { reset_publishable_attributes(Tag) }

    it "serializes to a hash with only the publishable attributes" do
      expect(subject.publishable_hash).to eq expected_hash
    end
  end
end
