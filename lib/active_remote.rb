require 'active_attr'
require 'active_model'
require 'protobuf'

require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'active_support/json'

require 'active_remote/core_ext/date_time'
require 'active_remote/core_ext/date'
require 'active_remote/core_ext/integer'

require 'active_remote/base'
require 'active_remote/config'
require 'active_remote/errors'

require 'active_remote/version'

module ActiveRemote
  def self.config
    @config ||= ::ActiveRemote::Config.new
  end

  # Initialize the config
  config
end

require 'active_remote/railtie' if defined?(Rails)
