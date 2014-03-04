require 'spec_helper'

describe ActiveRemote::ScopeKeys do
  let(:_scope_keys) { ['user_guid', 'name'] }
  let(:tag_hash) { { 'guid' => 'TAG-123', 'user_guid' => 'USR-123', 'name' => 'teh tag' } }
  let(:tag) { Tag.new(tag_hash) }

  context '.scope_key' do
    let(:keys) { [:user_guid, :name] }

    it 'adds scope_key to scope_keys' do
      Tag.scope_key(keys)
      Tag.scope_keys.count.should eq(2)
    end
  end

  context '.scope_keys' do
    before { Tag.better_stub(:_scope_keys).and_return(_scope_keys) }

    it 'combines primary key with _scope_keys' do
      Tag.scope_keys.should eq(['guid'] + _scope_keys)
    end
  end

  context '#scope_keys' do
    it 'should call class method' do
      Tag.better_receive(:scope_keys)
      Tag.new.scope_keys
    end
  end

  context '#scope_key_hash' do
    before { Tag.better_stub(:_scope_keys).and_return(_scope_keys) }

    it 'returns a attribute hash of scope_keys' do
      tag.scope_key_hash.should eq(tag_hash)
    end
  end
end
