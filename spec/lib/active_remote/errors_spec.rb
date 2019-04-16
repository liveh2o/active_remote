require "spec_helper"

describe ::ActiveRemote::RemoteRecordNotSaved do
  let(:record) { ::Tag.new }

  before do
    record.errors[:base] << "Some error one!"
    record.errors[:base] << "Some error two!"
  end

  context "when an active remote record is used" do
    it "uses embedded errors in message" do
      expect { fail(::ActiveRemote::RemoteRecordNotSaved, record) }
        .to raise_error(ActiveRemote::RemoteRecordNotSaved, "Some error one!, Some error two!")
    end
  end

  context "when a string is used" do
    it "uses the string in the error message" do
      expect { fail(::ActiveRemote::RemoteRecordNotSaved, "something bad happened") }
        .to raise_error(ActiveRemote::RemoteRecordNotSaved, "something bad happened")
    end
  end

  context "when no message is used" do
    it "raises the error" do
      expect { raise(::ActiveRemote::RemoteRecordNotSaved) }
        .to raise_error(ActiveRemote::RemoteRecordNotSaved)
    end
  end
end
