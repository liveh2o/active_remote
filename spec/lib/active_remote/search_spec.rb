require 'spec_helper'

describe ActiveRemote::Search do
  describe ".search" do
    context "given args that respond to :to_hash" do
      it "searches with the given args"

      it "returns serialized records"

      context "when record serialization is disabled" do
        it "returns the remote response"
      end
    end

    context "given args that don't respond to :to_hash" do
      it "raises an exception"
    end
  end

  describe "#_active_remote_search" do
    it "runs callbacks"

    it "searches with the given args"

    it "auto-paginates records"

    context "when the auto paging is disabled" do
      it "doesn't auto-paginate"
    end

    context "given args that include pagination" do
      it "doesn't auto-paginate"
    end
  end
end
