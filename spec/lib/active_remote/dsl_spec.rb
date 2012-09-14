require 'spec_helper'

describe ActiveRemote::DSL do
  before {
    reset_dsl_variables(Tag)
  }
  after {
    Tag.service_class Generic::Remote::TagService
  }

  describe ".app_name" do
    context "when given a value" do
      it "sets @app_name to the value" do
        Tag.app_name :foo
        Tag.app_name.should eq :foo
      end
    end
  end

  describe ".attr_publishable" do
    it "appends given attributes to @publishable_attributes"
  end

  describe ".auto_paging_size" do
    context "when given a value" do
      it "sets @auto_paging_size to the value" do
        Tag.auto_paging_size 100
        Tag.auto_paging_size.should eq 100
      end
    end
  end

  describe ".namespace" do
    context "when given a value" do
      it "sets @namespace to the value" do
        Tag.namespace :foo
        Tag.namespace.should eq :foo
      end
    end
  end

  describe ".service_class" do
    context "when nil" do
      it "determines the service class" do
        Tag.namespace :generic
        Tag.app_name :remote

        Tag.service_class.should eq Generic::Remote::TagService
      end
    end

    context "when given a value" do
      it "sets @service_class to the value" do
        Tag.service_class Generic::Remote::TagService
        Tag.service_class.should eq Generic::Remote::TagService
      end
    end
  end

  describe ".service_name" do
    context "when nil" do
      it "determines the service name" do
        Tag.service_name.should eq :tag_service
      end
    end

    context "when given a value" do
      it "sets @service_name to the value" do
        Tag.service_name :foo
        Tag.service_name.should eq :foo
      end
    end
  end
end
