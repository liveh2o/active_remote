require 'rubygems'
require 'bundler'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

Bundler.require(:default, :development, :test)

require 'protobuf/rspec'
require 'support/helpers'

$LOAD_PATH << ::File.expand_path('../support/protobuf', __FILE__)
require 'support/protobuf'
require 'support/models'

RSpec.configure do |config|
  config.include Protobuf::RSpec::Helpers
end
