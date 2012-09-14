require 'spec_helper'

describe ActiveRemote::RPC do
  let(:active_remote) { Baz }

  subject { active_remote.new }

  describe ".request" do
    let(:message) { double(:message) }

    before {
      active_remote.stub(:request_type)
      active_remote.stub(:build_message).and_return(message)
    }

    it "builds an RPC request" do
      active_remote.request(:create, {}).should eq message
    end
  end

  describe ".request_type" do
    it "fetches the request type for the given RPC method"
  end

  describe "#_execute" do
    let(:request) { double(:request) }

    before {
      active_remote.service_class Foo::Bar::BazService
    }
    after { reset_dsl_variables(active_remote) }

    it "calls the given RPC method" do
      mock_remote_service(active_remote.service_class, :create, :response => double(:to_hash => {}))
      subject._execute(:create, request)
    end

    it "sets the last request" do
      mock_remote_service(active_remote.service_class, :create, :response => double(:to_hash => {}))

      subject._execute(:create, request)
      subject.last_request.should eq(request)
    end

    context "when request args is a hash" do
      let(:args){ Hash.new }
      let(:request) { double(:request) }

      before {
        subject.stub(:request).and_return(request)
        mock_remote_service(active_remote.service_class, :create, :response => double(:to_hash => {}))
      }

      it "creates a request" do
        subject.should_receive(:request).with(:create, args)
        subject._execute(:create, args)
      end
    end

    context "when a request succeeds" do
      let(:success_response) { double(:status => 'success', :awesome_town => true, :to_hash => {}) }

      before {
        mock_remote_service(active_remote.service_class, :create, :response => success_response)
      }

      it "sets the last response" do
        subject._execute(:create, request)
        subject.last_response.should eq(success_response)
      end
    end

    context "when a request fails" do
      let(:error_response) { double(:error, :message => "Boom goes the dynamite!") }

      before {
        mock_remote_service(active_remote.service_class, :create, :error => error_response)
      }

      it "raises an exception" do
        expect { subject._execute(:create, request) }.to raise_error(ActiveRemote::ActiveRemoteError)
      end
    end
  end
end
