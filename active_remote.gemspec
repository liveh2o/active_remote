# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_remote/version"

Gem::Specification.new do |s|
  s.name          = "active_remote"
  s.version       = ActiveRemote::VERSION
  s.authors       = ["MDev"]
  s.email         = ["dev@moneydesktop.com"]
  s.homepage      = "https://git.moneydesktop.com/dev/active_remote"
  s.description   = %q{ActiveRecord Protobuf integration}
  s.summary       = s.description

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  ##
  # Dependencies
  #
  s.add_dependency "activemodel"
  s.add_dependency "protobuf"

  ##
  # Development Dependencies
  #
  s.add_development_dependency "rake"
  s.add_development_dependency "geminabox"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-pride"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "protobuf-rspec"
  s.add_development_dependency "simplecov"
end
