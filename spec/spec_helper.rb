require 'rubygems'
require 'bundler'
Bundler.require(:default, :development, :test)
require 'protobuf/rspec'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.include Protobuf::RSpec::Helpers
#  config.filter_run :focus
end
