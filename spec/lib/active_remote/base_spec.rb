require "spec_helper"

RSpec.describe ActiveRemote::Base do
  describe "#initialize" do
    it "runs callbacks" do
      expect_any_instance_of(described_class).to receive(:run_callbacks).with(:initialize)
      described_class.new
    end
  end
end
