require "support/models/message_with_options"
require "support/models/author"
require "support/models/default_author"
require "support/models/category"
require "support/models/no_attributes"
require "support/models/post"
require "support/models/tag"

# For testing the DSL methods
module Another
  class TagService < Protobuf::Rpc::Service
  end
end
