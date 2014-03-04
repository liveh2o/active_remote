require 'spec_helper'

describe ActiveRemote::PrimaryKey do
  let(:tag) { Tag.new(:guid => 'TAG-123', :user_guid => 'USR-123') }
  let(:specified_primary_key) { [:guid, :user_guid] }

  before { Tag.instance_variable_set :@primary_key, nil }

  describe ".default_primary_key" do
    it 'returns array of :guid' do
      Tag.default_primary_key.should eq([:guid])
    end
  end

  describe 'primary_key' do
    context 'with no args' do
      it 'returns default primary key when no arguments are passed' do
        Tag.primary_key.should eq([:guid])
      end
    end

    context 'with args' do
      it 'returns a hash using default primary key' do
        Tag.primary_key(specified_primary_key).should eq(specified_primary_key)
      end
    end
  end

  describe "#primary_key" do
    context 'default' do
      let(:default_primary_key_hash) { { :guid => tag.guid } }

      it 'returns hash with guid' do
        tag.primary_key_hash.should eq(default_primary_key_hash)
      end
    end

    context 'class specified' do
      let(:specified_primary_key_hash) { { :guid => tag.guid, :user_guid => tag.user_guid } }
      before { Tag.__send__(:primary_key, specified_primary_key) }

      it 'should return hash of the specified primary key' do
        tag.primary_key_hash.should eq(specified_primary_key_hash)
      end
    end
  end
end
