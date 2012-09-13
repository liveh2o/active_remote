require 'spec_helper'

describe ActiveRemote::Base do
  describe "#initialize" do
    it "runs callbacks" do
      described_class.any_instance.should_receive(:run_callbacks).with(:initialize)
      described_class.new
    end
  end
end
