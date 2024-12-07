# frozen_string_literal: true

require_relative "lib/active_remote/version"

Gem::Specification.new do |spec|
  spec.version = ActiveRemote::VERSION
  spec.name = "active_remote"
  spec.authors = ["Adam Hutchison"]
  spec.email = ["liveh2o@gmail.com"]

  spec.summary = "Active Record for your platform"
  spec.description = "Active Remote provides Active Record-like object-relational mapping over RPC. It was written for use with Google Protocol Buffers, but could be extended to use any RPC data format."
  spec.homepage = "https://github.com/liveh2o/active_remote"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  ##
  # Dependencies
  #
  spec.add_dependency "activemodel", "~> 7.2.0"
  spec.add_dependency "activesupport", "~> 7.2.0"
  spec.add_dependency "protobuf", ">= 3.0"
end
