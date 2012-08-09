#!/usr/bin/env rake
require "bundler/gem_tasks"

begin
  require "rspec"
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--color"
  end

  task :default => [:spec]
rescue => e
  warn "RSpec is not loaded"
end

Dir["lib/tasks/**/*.rake"].each { |ext| load ext } if defined?(Rake)
