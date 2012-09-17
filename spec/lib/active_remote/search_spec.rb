require 'spec_helper'

describe ActiveRemote::Search do
  describe ".find" do
    let(:args) { Hash.new }
    let(:record) { double(:record) }
    let(:records) { [ record ] }

    before { Tag.stub(:search).and_return(records) }

    it "searches with the given args" do
      Tag.should_receive(:search).with(args)
      Tag.find(args)
    end

    context "when records are returned" do
      it "returns the first record" do
        Tag.find(args).should eq record
      end
    end

    context "when no records are returned" do
      before { Tag.stub(:search).and_return([]) }

      it "raise an exception" do
        expect { Tag.find(args) }.to raise_error(::ActiveRemote::RemoteRecordNotFound)
      end
    end
  end

  describe ".paginated_search" do
    context "given args that respond to :to_hash" do
      let(:args) { Hash.new }

      before {
        Tag.any_instance.stub(:_active_remote_search)
      }

      it "searches with the given args" do
        Tag.any_instance.should_receive(:_active_remote_search).with(args)
        Tag.paginated_search(args)
      end

      it "returns records" do
        records = double(:records)

        Tag.any_instance.stub(:serialize_records).and_return(records)
        Tag.paginated_search(args).should eq records
      end

      context "when will_paginate is loaded" do
        it "returns paginated records" do
          paginated_records = double(:paginated_records)
          records = double(:records, :paginate => paginated_records)

          Tag.any_instance.stub(:serialize_records).and_return(records)
          Tag.paginated_search(args).should eq paginated_records
        end
      end
    end

    context "given args that don't respond to :to_hash" do
      let(:request) { double(:request) }

      it "raises an exception" do
        expect { described_class.paginated_search(request) }.to raise_exception
      end
    end
  end

  describe ".search" do
    context "given args that respond to :to_hash" do
      let(:args) { Hash.new }

      before {
        Tag.any_instance.stub(:_active_remote_search)
      }

      it "searches with the given args" do
        Tag.any_instance.should_receive(:_active_remote_search).with(args)
        Tag.search(args)
      end

      it "returns records" do
        records = double(:records)

        Tag.any_instance.stub(:serialize_records).and_return(records)
        Tag.search(args).should eq records
      end
    end

    context "given args that don't respond to :to_hash" do
      let(:request) { double(:request) }

      it "raises an exception" do
        expect { described_class.search(request) }.to raise_exception
      end
    end
  end

  describe "#_active_remote_search" do
    let(:args) { Hash.new }
    let(:pagination) { double(:pagination, :total_pages => 1) }
    let(:options) { double(:options, :pagination => pagination) }
    let(:last_response) {
      MessageWithOptions.new(:records => [], :options => options)
    }

    subject { Tag.new }

    before { subject.stub(:last_response).and_return(last_response) }

    it "runs callbacks" do
      subject.should_receive(:run_callbacks).with(:search)
      subject._active_remote_search(args)
    end

    it "auto-paginates" do
      subject.should_receive(:_execute).with(:search, args)

      subject._active_remote_search(args)
    end

    context "when auto paging" do
      let(:record) { double(:record) }
      let(:pagination) { double(:pagination, :total_pages => 2) }
      let(:last_response) {
        MessageWithOptions.new(:records => [ record ], :options => options)
      }

      it "collects results from each paging call" do
        subject.stub(:_execute)

        records = subject._active_remote_search(args)
        records.should eq [ record, record ]
      end
    end

    context "given args that include pagination" do
      let(:args) { { :options => { :pagination => Hash.new } } }

      it "doesn't auto-paginate" do
        subject.should_receive(:_execute).with(:search, args)

        subject._active_remote_search(args)
      end
    end
  end

  describe "#reload" do
    let(:args) { { :guid => 'foo' } }
    let(:attributes) { HashWithIndifferentAccess.new }

    subject { Tag.new(args) }

    before {
      subject.stub(:_active_remote_search)
      subject.stub(:last_response).and_return(attributes)
    }

    it "reloads the record" do
      subject.should_receive(:_active_remote_search).with(args)
      subject.reload
    end

    it "assigns new attributes" do
      subject.should_receive(:assign_attributes).with(attributes)
      subject.reload
    end
  end
end
