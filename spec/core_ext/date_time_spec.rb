require 'spec_helper'

describe DateTime do
  describe "#to_i" do
    it "does not raise errors bj" do
      expect { subject.to_i }.to_not raise_error
    end
  end
end
