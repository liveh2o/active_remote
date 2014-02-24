require 'spec_helper'

describe ActiveRemote::Serializers::Protobuf::Fields do
  describe ".from_attributes" do
    let(:ready_value) { { :records => [ { :name => 'Cool Post', :errors => [ { :message => 'Boom!' } ] } ] } }
    let(:value) { { :records => { :name => 'Cool Post', :errors => { :message => 'Boom!' } } } }

    it "gets protobuf-ready fields from attributes" do
      described_class.from_attributes(Generic::Remote::Posts, value).should eq ready_value
    end
  end
end

describe ActiveRemote::Serializers::Protobuf::Field do
  describe ".from_attribute" do
    context "when field is a repeated message" do
      let(:field) { Generic::Remote::Posts.get_field(:records) }

      context "and the value is not an array" do
        let(:ready_value) { [ { :name => 'Cool Post', :errors => [ { :message => 'Boom!' } ] } ] }
        let(:value) { { :name => 'Cool Post', :errors => { :message => 'Boom!' } } }

        it "gets protobuf-ready fields from the value" do
          described_class.from_attribute(field, value).should eq ready_value
        end
      end
    end

    context "when field is a message" do
      let(:field) { Generic::Remote::Post.get_field(:category) }

      context "and value is a hash" do
        let(:ready_value) { { :name => 'Film', :errors => [ { :message => 'Boom!' } ] } }
        let(:value) { { :name => 'Film', :errors => { :message => 'Boom!' } } }

        it "gets protobuf-ready fields from the value" do
          described_class.from_attribute(field, value).should eq ready_value
        end
      end
    end

    context "when field is repeated" do
      let(:field) { Generic::Remote::PostRequest.get_field(:name) }

      context "and the value is not an array" do
        let(:ready_value) { [ 'Cool Post' ] }
        let(:value) { 'Cool Post' }

        it "gets protobuf-ready fields from the value" do
          described_class.from_attribute(field, value).should eq ready_value
        end
      end
    end
  end
end
