require 'support/protobuf/tag.pb'

##
# Define a generic class that inherits from active remote base
#
class Tag < ::ActiveRemote::Base
  service_class ::Generic::Remote::TagService

  attribute :guid
  attribute :name
  attribute :updated_at

end
