require 'spec_helper'

describe ActiveRemote::RPC do
  subject { Tag.new }

  describe ".remote_call" do
    let(:args) { double(:args) }
    let(:response) { double(:response) }

    let(:rpc) { ::ActiveRemote::RPCAdapters::ProtobufAdapter.new(::Tag.service_class) }

    before { rpc.better_stub(:execute).and_return(response) }
    before { ::Tag.better_stub(:rpc).and_return(rpc) }

    it "calls the given RPC method" do
      expect(Tag.rpc).to receive(:execute).with(:remote_method, args)
      Tag.remote_call(:remote_method, args)
    end

    it "returns the response" do
      allow(Tag.rpc).to receive(:execute).and_return(response)
      expect(Tag.remote_call(:remote_method, args)).to eq response
    end
  end

  describe ".request" do
    let(:attributes) { Hash.new }

    it "builds an RPC request" do
      expect(Tag.request(:create, attributes)).to eq Generic::Remote::Tag.new(attributes)
    end
  end

  describe ".request_type" do
    it "fetches the request type for the given RPC method" do
      expect(Tag.request_type(:search)).to eq Generic::Remote::TagRequest
    end
  end

  describe "#execute" do
    let(:request) { double(:request) }

    it "calls the given RPC method" do
      mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))
      subject.execute(:create, request)
    end

    it "sets the last request" do
      mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))

      subject.execute(:create, request)
      expect(subject.last_request).to eq(request)
    end

    context "when request args is a hash" do
      let(:args){ Hash.new }
      let(:request) { double(:request) }

      before {
        allow(subject).to receive(:request).and_return(request)
        mock_remote_service(Tag.service_class, :create, :response => double(:to_hash => {}))
      }

      it "creates a request" do
        expect(subject).to receive(:request).with(:create, args)
        subject.execute(:create, args)
      end
    end

    context "when a request succeeds" do
      let(:success_response) { double(:status => 'success', :awesome_town => true, :to_hash => {}) }

      before {
        mock_remote_service(Tag.service_class, :create, :response => success_response)
      }

      it "sets the last response" do
        subject.execute(:create, request)
        expect(subject.last_response).to eq(success_response)
      end
    end

    context "when a request fails" do
      let(:error_response) { double(:error, :message => "Boom goes the dynamite!") }

      before {
        mock_remote_service(Tag.service_class, :create, :error => error_response)
      }

      it "raises an exception" do
        expect { subject.execute(:create, request) }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end
end
