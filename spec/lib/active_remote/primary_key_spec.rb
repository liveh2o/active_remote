require 'spec_helper'

describe ActiveRemote::PrimaryKey do
  let(:tag) { Tag.new(:id => '1234', :guid => 'TAG-123', :user_guid => 'USR-123') }

  before { Tag.instance_variable_set :@primary_key, nil }

  describe ".default_primary_key" do
    it 'returns array of :guid' do
      Tag.default_primary_key.should eq(:guid)
    end
  end

  describe 'primary_key' do
    context 'with no args' do
      it 'returns default primary key when no arguments are passed' do
        Tag.primary_key.should eq(:guid)
      end
    end

    context 'with args' do
      let(:specified_primary_key) { :name }

      it 'returns a hash using default primary key' do
        Tag.primary_key(specified_primary_key).should eq(specified_primary_key)
      end
    end
  end

  describe "#primary_key" do
    it 'calls the class method' do
      Tag.better_receive(:primary_key)
      Tag.new.primary_key
    end
  end
end
