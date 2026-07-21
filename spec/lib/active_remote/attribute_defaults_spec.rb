require "spec_helper"

RSpec.describe "ActiveRemote attribute defaults" do
  subject(:author) { DefaultAuthor.new }

  it "applies a proc default, cast to the attribute type" do
    expect(author.guid).to eq("100") # lambda { 100 } cast through :string
  end

  it "applies a literal default" do
    expect(author.name).to eq("John Doe")
  end

  it "applies a default for an attribute with no explicit type" do
    expect(author.books).to eq([])
  end

  it "lets an assigned value override the default" do
    expect(DefaultAuthor.new(name: "Jane").name).to eq("Jane")
  end

  it "does not fall back to the default once explicitly set to nil" do
    expect(DefaultAuthor.new(name: nil).name).to be_nil
  end

  # NOTE: documents an ActiveModel caveat — a literal mutable default (e.g.
  # `default: []`) is a single shared object, so mutating it in place leaks
  # across instances. Use `default: -> { [] }` to get a fresh value per record.
  # If a future ActiveModel version starts dup-ing literal defaults, this spec
  # will flag the behavior change.
  it "shares a literal mutable default across instances (in-place mutation leaks)" do
    DefaultAuthor.new.books << :leaked
    expect(DefaultAuthor.new.books).to eq([:leaked])
  ensure
    DefaultAuthor.new.books.clear
  end

  it "does not apply defaults to models that declare none" do
    expect(Tag.new.name).to be_nil
  end
end
