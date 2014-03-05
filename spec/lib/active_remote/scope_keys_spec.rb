require 'spec_helper'

describe ActiveRemote::ScopeKeys do
  let(:_scope_keys) { ['user_guid'] }
  let(:scope_keys) { ['guid'] + ['user_guid'] }
  let(:tag_hash) { { :guid => 'TAG-123', :user_guid => 'USR-123', :name => 'teh tag' } }
  let(:tag) { Tag.new(tag_hash) }

  context '.scope_key' do
    let(:key) { :user_guid }

    it 'adds scope_key to _scope_keys' do
      Tag.scope_key(key)
      Tag._scope_keys.should eq(_scope_keys)
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
    let(:scope_key_hash) { { 'guid' => 'TAG-123', 'user_guid' => 'USR-123' } }
    before { tag.better_stub(:scope_keys).and_return(scope_keys) }

    it 'returns a attribute hash of scope_keys' do
      tag.scope_key_hash.should eq(scope_key_hash)
    end
  end
end
