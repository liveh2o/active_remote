require 'spec_helper'

describe ActiveRemote::DSL do
  before {
    reset_dsl_variables(Baz)
  }

  describe ".app_name" do
    context "when given a value" do
      it "sets @app_name to the value" do
        Baz.app_name :foo
        Baz.app_name.should eq :foo
      end
    end
  end

  describe ".attr_publishable" do
    it "appends given attributes to @publishable_attributes"
  end

  describe ".auto_paging_size" do
    context "when given a value" do
      it "sets @auto_paging_size to the value" do
        Baz.auto_paging_size 100
        Baz.auto_paging_size.should eq 100
      end
    end
  end

  describe ".namespace" do
    context "when given a value" do
      it "sets @namespace to the value" do
        Baz.namespace :foo
        Baz.namespace.should eq :foo
      end
    end
  end

  describe ".service_class" do
    context "when nil" do
      it "determines the service class" do
        Baz.namespace :foo
        Baz.app_name :bar

        Baz.service_class.should eq Foo::Bar::BazService
      end
    end

    context "when given a value" do
      it "sets @service_class to the value" do
        Baz.service_class Foo::Bar::BazService
        Baz.service_class.should eq Foo::Bar::BazService
      end
    end
  end

  describe ".service_name" do
    context "when nil" do
      it "determines the service name" do
        Baz.service_name.should eq :baz_service
      end
    end

    context "when given a value" do
      it "sets @service_name to the value" do
        Baz.service_name :foo
        Baz.service_name.should eq :foo
      end
    end
  end
end

##
# Reset all DSL variables so specs don't interfere with each other.
#
def reset_dsl_variables(klass)
  klass.send(:instance_variable_set, :@app_name, nil)
  klass.send(:instance_variable_set, :@auto_paging_size, nil)
  klass.send(:instance_variable_set, :@namespace, nil)
  klass.send(:instance_variable_set, :@publishable_attributes, nil)
  klass.send(:instance_variable_set, :@service_class, nil)
  klass.send(:instance_variable_set, :@service_name, nil)
end
require 'spec_helper'

describe ActiveRemote::DSL do
  before {
    reset_dsl_variables(Baz)
  }

  describe ".app_name" do
    context "when given a value" do
      it "sets @app_name to the value" do
        Baz.app_name :foo
        Baz.app_name.should eq :foo
      end
    end
  end

  describe ".attr_publishable" do
    it "appends given attributes to @publishable_attributes"
  end

  describe ".auto_paging_size" do
    context "when given a value" do
      it "sets @auto_paging_size to the value" do
        Baz.auto_paging_size 100
        Baz.auto_paging_size.should eq 100
      end
    end
  end

  describe ".namespace" do
    context "when given a value" do
      it "sets @namespace to the value" do
        Baz.namespace :foo
        Baz.namespace.should eq :foo
      end
    end
  end

  describe ".service_class" do
    context "when nil" do
      it "determines the service class" do
        Baz.namespace :foo
        Baz.app_name :bar

        Baz.service_class.should eq Foo::Bar::BazService
      end
    end

    context "when given a value" do
      it "sets @service_class to the value" do
        Baz.service_class Foo::Bar::BazService
        Baz.service_class.should eq Foo::Bar::BazService
      end
    end
  end

  describe ".service_name" do
    context "when nil" do
      it "determines the service name" do
        Baz.service_name.should eq :baz_service
      end
    end

    context "when given a value" do
      it "sets @service_name to the value" do
        Baz.service_name :foo
        Baz.service_name.should eq :foo
      end
    end
  end
end

##
# Reset all DSL variables so specs don't interfere with each other.
#
def reset_dsl_variables(klass)
  klass.send(:instance_variable_set, :@app_name, nil)
  klass.send(:instance_variable_set, :@auto_paging_size, nil)
  klass.send(:instance_variable_set, :@namespace, nil)
  klass.send(:instance_variable_set, :@publishable_attributes, nil)
  klass.send(:instance_variable_set, :@service_class, nil)
  klass.send(:instance_variable_set, :@service_name, nil)
end
