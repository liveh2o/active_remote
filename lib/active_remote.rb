require 'active_model'
require 'active_support'
require 'active_support/core_ext'
require 'protobuf'

require 'active_remote/base'
require 'active_remote/config'
require 'active_remote/errors'
require 'active_remote/version'

module ActiveRemote
  def self.config
    @config ||= Config.new
  end

  # Initialize the config
  config
end

require 'active_remote/railtie' if defined?(Rails)
