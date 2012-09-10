require 'spec_helper'

describe ActiveRemote::DSL do
  describe ".app" do
    context "when given a value" do
      it "sets @app to the value"
    end
  end

  describe ".attr_publishable" do
    it "appends given attributes to @publishable_attributes"
  end

  describe ".namespace" do
    context "when given a value" do
      it "sets @namespace to the value"
    end
  end

  describe ".service" do
    context "when nil" do
      it "raises an exception"
    end

    context "when given a value" do
      it "sets @service to the value"
    end
  end

  describe ".service_class" do
    context "when nil" do
      it "determines the service class"
    end

    context "when given a value" do
      it "sets @service_class to the value"
    end
  end
end
