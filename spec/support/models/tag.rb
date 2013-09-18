require 'support/protobuf/tag.pb'

##
# Define a generic class that inherits from active remote base
#
class Tag < ::ActiveRemote::Base
  service_class ::Generic::Remote::TagService

  attribute :guid
  attribute :name
  attribute :updated_at

  after_update :after_update_callback
  after_create :after_create_callback

  def after_create_callback
  end

  def after_update_callback
  end
end
