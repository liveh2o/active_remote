require 'spec_helper'
require 'atlas/abacus/tag_service'

describe ActiveRemote::Base do
  let(:message) do
    double(:protos, :fields => [ double(:field, :name => :records, :repeated? => true) ], :records => [])
  end
  let(:remote_with_errors) {
    remote = described_class.new
    remote.stub_chain(:last_response, :message).and_return("Hello World!")
    remote.stub(:has_errors?).and_return(true)
  }

  # TODO: Create proto messages & endpoints specifically for these tests.
  # They will be more robust if they don't rely on proto messages in Atlas.
  context "when building messages" do
    let(:records) { [ { :name => 'Foo' }, { :name => 'Bar' } ] }
    let(:attributes) { records.first }

    it "creates a message" do
      pending
      described_class.service_class Abacus::TagService
      expected_message = Abacus::Tag.new(attributes)

      package = subject.request(:create, attributes)
      package.should be_similar_to(expected_message)
    end

    it "creates a bulk message" do
      pending
      described_class.service_class Abacus::TagService
      expected_message = Abacus::Tags.new

      package = described_class.request(:create_all, records, :bulk => true)
      package.should be_similar_to(expected_message)
    end

    it "creates a message with nested messages" do
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
