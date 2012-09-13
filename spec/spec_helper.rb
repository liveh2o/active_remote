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
