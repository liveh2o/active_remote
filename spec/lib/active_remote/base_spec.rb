require "spec_helper"

describe ActiveRemote::Base do
  describe "#initialize" do
    it "runs callbacks" do
      expect_any_instance_of(described_class).to receive(:run_callbacks).with(:initialize)
      described_class.new
    end
  end

  describe "filtered_attributes" do
    describe "single attribute" do
      let(:subject) { ::User.new(:password => "foobar") }

      it "#inspect doesn't show the password" do
        expect(subject.inspect).not_to include("foobar")
      end

      it "#inspect just equals the class name" do
        expect(subject.inspect).to eq("#<User>")
      end
    end

    describe "multiple attributes" do
      let(:subject) { ::Author.new(:name => "foo", :age => 15) }

      it "#inspect doesn't show the name" do
        expect(subject.inspect).not_to include("foo")
      end

      it "#inspect doesn't show the birthday" do
        expect(subject.inspect).not_to include("15")
      end

      it "#inspect just equals the class name" do
        expect(subject.inspect).to eq("#<Author>")
      end
    end
  end
end
