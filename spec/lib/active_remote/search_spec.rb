require "spec_helper"

RSpec.describe ActiveRemote::Search do
  let(:records) { [Generic::Remote::Tag.new(guid: "123")] }
  let(:response) { Generic::Remote::Tags.new(records: records) }

  describe ".find" do
    let(:args) { {} }
    let(:record) { double(:record) }
    let(:records) { [record] }

    before { allow(Tag).to receive(:search).and_return(records) }

    it "searches with the given args" do
      expect(Tag).to receive(:search).with(args)
      Tag.find(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        expect(Tag.find(args)).to eq record
      end
    end

    context "when no records are returned" do
      before { allow(Tag).to receive(:search).and_return([]) }

      it "raise an exception" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound)
      end

      it "gives the class of the remote record not found in the message" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound, /Tag/)
      end
    end
  end

  describe ".find_by" do
    let(:args) { {} }
    let(:record) { double(:record) }
    let(:records) { [record] }

    before { allow(Tag).to receive(:search).and_return(records) }

    it "searches with the given args" do
      expect(Tag).to receive(:search).with(args)
      Tag.find_by(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        expect(Tag.find_by(args)).to eq record
      end
    end

    context "when no records are returned" do
      before { allow(Tag).to receive(:search).and_return([]) }

      it "returns nil" do
        expect(Tag.find_by(args)).to be_nil
      end
    end
  end

  describe ".search" do
    let(:serialized_records) { [Tag.instantiate(guid: "123")] }
    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class, ::Tag.endpoints) }

    before do
      allow(rpc).to receive(:execute).and_return(response)
      allow(::Tag).to receive(:rpc).and_return(rpc)
    end

    context "given args that respond to :to_hash" do
      let(:args) { {} }

      it "searches with the given args" do
        expect(Tag.rpc).to receive(:execute).with(:search, args)
        Tag.search(args)
      end

      it "returns records" do
        records = Tag.search(args)
        expect(records).to eq serialized_records
      end
    end

    context "given args that don't respond to :to_hash" do
      let(:request) { Object.new }

      it "raises an exception" do
        expect { Tag.search(request) }.to raise_error(::RuntimeError, /Invalid parameter/)
      end
    end

    # The docs advertise a protobuf request or Active Remote object, not just a hash.
    context "given a protobuf request object" do
      it "normalizes it to a hash" do
        expect(Tag.rpc).to receive(:execute).with(:search, {guid: ["123"]})
        Tag.search(::Generic::Remote::TagRequest.new(guid: ["123"]))
      end
    end

    context "given an Active Remote object" do
      it "searches with its attributes" do
        expect(Tag.rpc).to receive(:execute).with(:search, hash_including("guid" => "123"))
        Tag.search(Tag.new(guid: "123"))
      end
    end
  end

  # These take .search's argument forms but hand them to create/new.
  describe "first_or_* argument handling" do
    let(:empty_response) { Generic::Remote::Tags.new(records: []) }
    let(:created) { Generic::Remote::Tag.new(guid: "NEW", name: "foo") }
    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class, ::Tag.endpoints) }
    let(:requests) { [] }

    before do
      allow(::Tag).to receive(:rpc).and_return(rpc)
      allow(rpc).to receive(:execute) do |endpoint, args|
        requests << [endpoint, args]
        (endpoint == :search) ? empty_response : created
      end
    end

    it "creates from a protobuf request when nothing is found" do
      tag = Tag.first_or_create(::Generic::Remote::TagRequest.new(name: ["foo"]))

      expect(tag.guid).to eq("NEW")
    end

    it "creates! from a protobuf request when nothing is found" do
      tag = Tag.first_or_create!(::Generic::Remote::TagRequest.new(name: ["foo"]))

      expect(tag.guid).to eq("NEW")
    end

    it "initializes from a protobuf request when nothing is found" do
      tag = Tag.first_or_initialize(::Generic::Remote::TagRequest.new(guid: ["G"]))

      expect(tag).to be_new_record
    end

    it "returns the found record without creating" do
      allow(rpc).to receive(:execute).and_return(Generic::Remote::Tags.new(records: [Generic::Remote::Tag.new(guid: "OLD")]))

      expect(Tag.first_or_create(name: "foo").guid).to eq("OLD")
    end

    # Search fields are repeated, but the matching attribute is scalar.
    context "when a search field is repeated but the attribute is not" do
      it "unwraps the value before initializing" do
        tag = Tag.first_or_initialize(::Generic::Remote::TagRequest.new(name: ["foo"]))

        expect(tag.name).to eq("foo")
      end

      it "still searches with the repeated value" do
        Tag.first_or_initialize(::Generic::Remote::TagRequest.new(name: ["foo"]))

        expect(requests).to include([:search, {name: ["foo"]}])
      end

      it "unwraps the value before creating" do
        Tag.first_or_create(::Generic::Remote::TagRequest.new(name: ["foo"]))

        expect(requests).to include([:create, hash_including("name" => "foo")])
      end

      it "refuses to build a record when the search matched on several values" do
        expect {
          Tag.first_or_initialize(::Generic::Remote::TagRequest.new(name: %w[foo bar]))
        }.to raise_error(ArgumentError, /holds a single value, but 2 were given/)
      end

      it "leaves an attribute that accepts the array alone" do
        allow(::DefaultAuthor).to receive(:rpc).and_return(rpc)

        author = DefaultAuthor.first_or_initialize(books: %w[foo bar])

        expect(author.books).to eq(%w[foo bar])
      end
    end
  end

  describe "#reload" do
    let(:args) { attributes.slice("guid", "user_guid") }
    let(:attributes) { HashWithIndifferentAccess.new(guid: "foo", name: "bar", updated_at: nil, user_guid: "baz") }

    subject { Tag.new(args) }

    before { allow(Tag).to receive(:find).and_return(Tag.new(attributes)) }

    it "reloads the record" do
      expect(Tag).to receive(:find).with(subject.scope_key_hash)
      subject.reload
    end

    it "assigns new attributes" do
      subject.reload
      expect(subject.attributes).to eq attributes
    end

    # A reloaded record isn't new; leaving the flag set duplicates it on save.
    it "marks the record as persisted" do
      expect { subject.reload }.to change { subject.new_record? }.from(true).to(false)
    end
  end
end
