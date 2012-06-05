# -*- encoding: utf-8 -*-
require File.expand_path('../lib/activeremote/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["BJ Neilsen"]
  gem.email         = ["bj.neilsen@gmail.com"]
  gem.description   = %q{ActiveRecord protobuf integration}
  gem.summary       = gem.description
  gem.homepage      = "http://www.moneydesktop.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "activeremote"
  gem.require_paths = ["lib"]
  gem.version       = Activeremote::VERSION
end
