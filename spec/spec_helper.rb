require 'rubygems'
require 'bundler'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

Bundler.require(:default, :development, :test)

RSpec.configure do |config|
  config.include Protobuf::RSpec::Helpers
end

##
# Define a generic class that inherits from active remote base
#
class Baz < ::ActiveRemote::Base
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
# Define a generic class for use when testing the service class
#
module Foo
  module Bar
    class BazService
    end
  end
end
