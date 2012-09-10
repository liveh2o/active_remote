require 'spec_helper'

describe ActiveRemote::RPC do

  describe ".request" do
    it "builds an RPC request"
  end

  describe ".request_type" do
    it "fetches the request type for the given RPC method"
  end

  describe "#_execute" do
    let(:request) { double(:request) }

    before {
      described_class.service_class FooBarService
      mock_remote_service(described_class.service_class, :create, :response => double(:to_hash => {}))
    }
    after { described_class.service_class nil }

    xit "calls the given RPC method" do
      # The expectation is handled by mock_remote_service
      subject._execute(:create, request)
    end

    xit "sets the last request" do
      subject._execute(:create, request)
      subject.last_request.should eq(request)
    end

    context "when request args is a hash" do
      let(:args){ Hash.new }
      let(:request) { double(:request) }

      before {
        subject.stub(:request).and_return(request)
      }

      xit "creates a request" do
        described_class.should_receive(:request).with(:create, args)
        subject._execute(:create, args)
      end
    end

    context "when a request succeeds" do
      let(:success_response) { double(:status => 'success', :awesome_town => true, :to_hash => {}) }

      before {
        mock_remote_service(described_class.service_class, :create, :response => success_response)
      }

      xit "sets the last response" do
        subject._execute(:create, request)
        subject.last_response.should eq(success_response)
      end
    end

    context "when a request fails" do
      let(:error_response) { double(:error, :message => "Boom goes the dynamite!") }

      before {
        mock_remote_service(described_class.service_class, :create, :error => error_response)
      }

      xit "raises an exception" do
        subject.execute!(:create, request)
        subject.has_errors?.should be_true
      end
    end
  end
end
