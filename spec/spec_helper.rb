require 'rubygems'
require 'bundler'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

Bundler.require(:default, :development, :test)

require 'support/protobuf'

RSpec.configure do |config|
  config.include Protobuf::RSpec::Helpers
end

##
# Define a generic class that inherits from active remote base
#
class Tag < ::ActiveRemote::Base
end

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

##
# Reset all DSL variables so specs don't interfere with each other.
#
def reset_dsl_variables(klass)
  klass.send(:instance_variable_set, :@app_name, nil)
  klass.send(:instance_variable_set, :@auto_paging_size, nil)
  klass.send(:instance_variable_set, :@namespace, nil)
  klass.send(:instance_variable_set, :@publishable_attributes, nil)
  klass.send(:instance_variable_set, :@service_class, nil)
  klass.send(:instance_variable_set, :@service_name, nil)
end
