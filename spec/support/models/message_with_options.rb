##
# Define a generic message with options that behaves like a protobuf search response
#
class MessageWithOptions
  attr_accessor :records, :options

  def initialize(attributes = {})
    @records = attributes.fetch(:records, nil)
    @options = attributes.fetch(:options, nil)
  end
end
