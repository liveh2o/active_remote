require 'spec_helper'

describe ActiveRemote::Bulk do
  shared_examples_for "a bulk method" do |bulk_method|
    let(:records) { [ Hash.new ] }
    let(:response) { double(:response, :records => []) }
    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class) }

    before { allow(rpc).to receive(:execute).and_return(response) }
    before { allow(::Tag).to receive(:rpc).and_return(rpc) }

    context "given an empty array" do
      let(:parsed_records) { { :records => records } }
      let(:records) { [] }

      it "calls #{bulk_method} with parsed records" do
        expect(rpc).to receive(:execute).with(bulk_method, parsed_records)
        Tag.__send__(bulk_method, records)
      end
    end

    context "given an array of record hashes" do
      let(:hash_record){ double(:record, :to_hash => {}) }
      let(:parsed_records) { { :records => records.map(&:to_hash) } }
      let(:records) { [ hash_record ] }

      it "calls #{bulk_method} with parsed records" do
        expect(rpc).to receive(:execute).with(bulk_method, parsed_records)
        Tag.__send__(bulk_method, records)
      end
    end

    context "given an array of remote records" do
      let(:parsed_records) { { :records => records.map(&:attributes) } }
      let(:records) { [ remote_record ] }
      let(:remote_record) { double(:remote, :attributes => {}) }

      it "calls #{bulk_method} with parsed records" do
        expect(rpc).to receive(:execute).with(bulk_method, parsed_records)
        Tag.__send__(bulk_method, records)
      end
    end

    context "given a bulk message" do
      let(:parsed_records) { { :records => records.map(&:to_hash) } }
      let(:tag) { Generic::Remote::Tag.new }
      let(:tags) { Generic::Remote::Tags.new(:records => [ tag ]) }

      it "calls #{bulk_method} with parsed records" do
        expect(rpc).to receive(:execute).with(bulk_method, parsed_records)
        Tag.__send__(bulk_method, tags)
      end
    end

    context "response with errors" do
      let(:record_with_errors) { double(:record, :errors => [double(:error, :messages => ["whine"], :field => "wat")], :to_hash => {}) }
      let(:response) { double(:response, :records => [record_with_errors]) }
      let(:tag) { Generic::Remote::Tag.new }
      let(:tags) { Generic::Remote::Tags.new(:records => [ tag ]) }

      it "sets the errors on the inflated ActiveRemote objects" do
        records = Tag.__send__(bulk_method, tags)
        expect(records.first.errors["wat"]).to eq(["whine"])
      end
    end
  end

  describe ".create_all" do
    it_behaves_like "a bulk method", :create_all
  end

  describe ".delete_all" do
    it_behaves_like "a bulk method", :delete_all
  end

  describe ".destroy_all" do
    it_behaves_like "a bulk method", :destroy_all
  end

  describe ".update_all" do
    it_behaves_like "a bulk method", :update_all
  end
end
