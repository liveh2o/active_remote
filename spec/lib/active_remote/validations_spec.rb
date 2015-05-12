require 'spec_helper'

describe ActiveRemote::Validations do
  let(:invalid_record) { ::Post.new }
  let(:valid_record) { ::Post.new(:name => 'test') }

  before { valid_record.stub(:create_or_update).and_return(true) }
  before { invalid_record.stub(:create_or_update).and_return(true) }

  describe 'save' do
    context 'valid record' do
      it 'returns true' do
        result = valid_record.save
        result.should be true
      end
    end

    context 'invalid record' do
      it 'returns false' do
        result = invalid_record.save
        result.should be false
      end
    end
  end

  describe 'save!' do
    context 'valid record' do
      it 'returns true' do
        result = valid_record.save!
        result.should be true
      end
    end

    context 'invalid record' do
      it 'raises invalid record error' do
        expect { invalid_record.save! }.to raise_error(ActiveRemote::RemoteRecordInvalid)
      end
    end
  end

  describe 'valid?' do
    context 'valid record' do
      it 'returns true' do
        result = valid_record.valid?
        result.should be true
      end
    end

    context 'invalid record' do
      it 'returns false' do
        result = invalid_record.valid?
        result.should be false
      end
    end
  end
end
