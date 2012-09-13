require 'spec_helper'

# TODO: Create proto messages & endpoints specifically for these tests.
# They will be more robust if they don't rely on proto messages in Atlas.
#
require 'atlas/abacus/tag_service'

describe ActiveRemote::Serializers::Protobuf do
  context "when building messages" do
    let(:records) { [ { :name => 'Foo' }, { :name => 'Bar' } ] }
    let(:attributes) { records.first }

    xit "creates a message" do
      pending
      described_class.service_class Abacus::TagService
      expected_message = Abacus::Tag.new(attributes)

      package = subject.request(:create, attributes)
      package.should be_similar_to(expected_message)
    end

    xit "creates a bulk message" do
      pending
      described_class.service_class Abacus::TagService
      expected_message = Abacus::Tags.new

      package = described_class.request(:create_all, records, :bulk => true)
      package.should be_similar_to(expected_message)
    end

    xit "creates a message with nested messages" do
      pending
      described_class.service_class Abacus::TransactionService
      records_hash = { :status => { :status => 7 }, :guid => 'GUID' }

      expected_message = Abacus::Transaction.new
      expected_message.guid = records_hash[:guid]
      expected_message.status = Status.new(records_hash.fetch(:status)) # status => HIDDEN

      message = subject.request(:update, records_hash)
      message.should be_similar_to(expected_message)
    end
  end
end
