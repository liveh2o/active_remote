require 'spec_helper'

# For testing the DSL methods
module Another
  class TagService < Protobuf::Rpc::Service
  end
end

describe ActiveRemote::DSL do
  before { reset_dsl_variables(Tag) }
  after { Tag.service_class Generic::Remote::TagService }

  describe ".attr_publishable" do
    after { reset_publishable_attributes(Tag) }

    it "appends given attributes to @publishable_attributes" do
      Tag.attr_publishable :guid
      Tag.attr_publishable :name

      expect(Tag.publishable_attributes).to match_array([ :guid, :name ])
    end
  end

  describe ".namespace" do
    context "when given a value" do
      it "sets @namespace to the value" do
        Tag.namespace :foo
        expect(Tag.namespace).to eq :foo
      end
    end
  end

  describe ".service_class" do
    context "when nil" do
      it "determines the service class" do
        Tag.namespace :another

        expect(Tag.service_class).to eq Another::TagService
      end
    end

    context "when given a value" do
      it "sets @service_class to the value" do
        Tag.service_class Generic::Remote::TagService
        expect(Tag.service_class).to eq Generic::Remote::TagService
      end
    end
  end

  describe ".service_name" do
    context "when nil" do
      it "determines the service name" do
        expect(Tag.service_name).to eq :tag_service
      end
    end

    context "when given a value" do
      it "sets @service_name to the value" do
        Tag.service_name :foo
        expect(Tag.service_name).to eq :foo
      end
    end
  end
end
