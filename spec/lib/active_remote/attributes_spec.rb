require "spec_helper"

describe ::ActiveRemote::Attributes do
  let(:model_class) do
    ::Class.new do
      include ::ActiveRemote::Attributes

      attribute :name
      attribute :address

      def self.name
        "TestClass"
      end
    end
  end
  subject { ::Author.new }

  describe "type casting" do
    let(:test_class) { ::TypecastedAuthor }

    describe "boolean" do
      it "casts to boolean" do
        record = test_class.new(:writes_fiction => "f")
        expect(record.writes_fiction).to eq(false)
      end
    end

    describe "datetime" do
      it "casts to datetime" do
        record = test_class.new(:birthday => "2016-01-01")
        expect(record.birthday).to eq(DateTime.parse("2016-01-01"))
      end

      context "invalid date" do
        it "sets attribute to nil" do
          record = test_class.new(:birthday => "23451234")
          expect(record.birthday).to be_nil
        end
      end
    end

    describe "float" do
      it "casts to float" do
        record = test_class.new(:net_sales => "2000.20")
        expect(record.net_sales).to eq(2000.2)
      end
    end

    describe "integer" do
      it "casts to integer" do
        record = test_class.new(:age => "40")
        expect(record.age).to eq(40)
      end
    end

    describe "string" do
      it "casts to string" do
        record = test_class.new(:guid => 1000)
        expect(record.guid).to eq("1000")
      end
    end
  end

  describe ".attribute" do
    context "a dangerous attribute" do
      it "raises an error" do
        expect { model_class.attribute(:timeout) }.to raise_error(::ActiveRemote::DangerousAttributeError)
      end
    end

    context "a harmless attribute" do
      it "creates an attribute with no options" do
        expect(model_class.attributes.values).to include(::ActiveRemote::AttributeDefinition.new(:name))
      end

      it "returns the attribute definition" do
        expect(model_class.attribute(:name)).to eq(::ActiveRemote::AttributeDefinition.new(:name))
      end

      it "defines an attribute reader that calls #attribute" do
        expect(subject).to receive(:attribute).with("name")
        subject.name
      end

      it "defines an attribute writer that calls #attribute=" do
        expect(subject).to receive(:attribute=).with("name", "test")
        subject.name = "test"
      end
    end
  end

  describe ".attribute!" do
    it "can create an attribute with no options" do
      model_class.attribute!(:first_name)
      expect(model_class.attributes.values).to include(::ActiveRemote::AttributeDefinition.new(:first_name))
    end

    it "returns the attribute definition" do
      expect(model_class.attribute!(:address)).to eq(::ActiveRemote::AttributeDefinition.new(:address))
    end
  end

  describe ".attributes" do
    it "can access AttributeDefinition with a Symbol" do
      expect(::Author.attributes[:name]).to eq(::ActiveRemote::AttributeDefinition.new(:name))
    end

    it "can access AttributeDefinition with a String" do
      expect(::Author.attributes["name"]).to eq(::ActiveRemote::AttributeDefinition.new(:name))
    end
  end

  describe ".inspect" do
    it "renders the class name" do
      expect(model_class.inspect).to match(/^TestClass\(.*\)$/)
    end

    it "renders the attribute names in alphabetical order" do
      expect(model_class.inspect).to match("(address, name)")
    end
  end

  describe "#==" do
    it "returns true when all attributes are equal" do
      expect(::Author.new(:guid => "test")).to eq(::Author.new(:guid => "test"))
    end

    it "returns false when compared to another type" do
      expect(::Category.new(:guid => "test")).to_not eq(::Author.new(:name => "test"))
    end
  end

  describe "#attributes" do
    context "when no attributes are defined" do
      it "returns an empty Hash" do
        expect(::NoAttributes.new.attributes).to eq({})
      end
    end

    context "when an attribute is defined" do
      it "returns the key value pairs" do
        subject.name = "test"
        expect(subject.attributes).to include("name" => "test")
      end

      it "returns a new Hash " do
        subject.attributes["foobar"] = "foobar"
        expect(subject.attributes).to_not include("foobar" => "foobar")
      end

      it "returns all attributes" do
        expect(subject.attributes.keys).to eq(["guid", "name", "user_guid", "chief_editor_guid", "editor_guid", "category_guid"])
      end
    end
  end

  describe "#inspect" do
    before { subject.name = "test" }

    it "includes the class name and all attribute values in alphabetical order by attribute name" do
      expect(subject.inspect).to eq(%(#<Author category_guid: nil, chief_editor_guid: nil, editor_guid: nil, guid: nil, name: "test", user_guid: nil>))
    end

    it "doesn't format the inspection string for attributes if the model does not have any" do
      expect(::NoAttributes.new.inspect).to eq(%(#<NoAttributes>))
    end
  end

  [:[], :read_attribute].each do |method|
    describe "##{method}" do
      context "when an attribute is not set" do
        it "returns nil" do
          expect(subject.send(method, :name)).to be_nil
        end
      end

      context "when an attribute is set" do
        before { subject.write_attribute(:name, "test") }

        it "returns the attribute using a Symbol" do
          expect(subject.send(method, :name)).to eq("test")
        end

        it "returns the attribute using a String" do
          expect(subject.send(method, "name")).to eq("test")
        end
      end

      it "raises when getting an undefined attribute" do
        expect { subject.send(method, :foobar) }.to raise_error(::ActiveRemote::UnknownAttributeError)
      end
    end
  end

  [:[]=, :write_attribute].each do |method|
    describe "##{method}" do
      it "raises ArgumentError with one argument" do
        expect { subject.send(method, :name) }.to raise_error(::ArgumentError)
      end

      it "raises ArgumentError with no arguments" do
        expect { subject.send(method) }.to raise_error(::ArgumentError)
      end

      it "sets an attribute using a Symbol and value" do
        expect { subject.send(method, :name, "test") }.to change { subject.attributes["name"] }.from(nil).to("test")
      end

      it "sets an attribute using a String and value" do
        expect { subject.send(method, "name", "test") }.to change { subject.attributes["name"] }.from(nil).to("test")
      end

      it "is able to set an attribute to nil" do
        subject.name = "test"
        expect { subject.send(method, :name, nil) }.to change { subject.attributes["name"] }.from("test").to(nil)
      end

      it "raises when setting an undefined attribute" do
        expect { subject.send(method, :foobar, "test") }.to raise_error(::ActiveRemote::UnknownAttributeError)
      end
    end
  end
end
