require 'spec_helper'

describe ActiveRemote::ScopeKeys do
  let(:key) { :user_guid }
  let(:_scope_keys) { [ 'user_guid' ] }
  let(:scope_keys) { [ 'guid' ] + _scope_keys }
  let(:tag) { Tag.new(tag_hash) }
  let(:tag_hash) { { :guid => 'TAG-123', :user_guid => 'USR-123', :name => 'teh tag' } }

  describe ".scope_key" do
    after { Tag._scope_keys = [] }

    it 'adds scope_key to _scope_keys' do
      Tag.scope_key(key)
      Tag._scope_keys.should eq(_scope_keys)
    end
  end

  describe ".scope_keys" do
    before { Tag.better_stub(:_scope_keys).and_return(_scope_keys) }

    it "combines primary key with _scope_keys" do
      Tag.scope_keys.should eq(['guid'] + _scope_keys)
    end
  end

  describe "#scope_keys" do
    it "returns the scope keys for the class" do
      Tag.new.scope_keys.should eq Tag.scope_keys
    end
  end

  describe "#scope_key_hash" do
    let(:scope_key_hash) { { 'guid' => 'TAG-123', 'user_guid' => 'USR-123' } }

    before { tag.better_stub(:scope_keys).and_return(scope_keys) }

    it "returns a attribute hash of scope_keys" do
      tag.scope_key_hash.should eq(scope_key_hash)
    end
  end
end
