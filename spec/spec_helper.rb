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

  # Turn deprecation warnings into errors with full backtrace.
  config.raise_errors_for_deprecations!

  # Verifies the existance of any stubbed methods, replaces better_receive and better_stub
  # https://www.relishapp.com/rspec/rspec-mocks/v/3-1/docs/verifying-doubles/partial-doubles
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
