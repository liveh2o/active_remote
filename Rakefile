#!/usr/bin/env rake
require "bundler/gem_tasks"
require "protobuf/tasks"
require "rspec/core/rake_task"

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Run specs (default)"
task :default, [] => :spec

desc "Remove protobuf definitions that have been compiled"
task :clean do
  FileUtils.rm(Dir.glob("spec/support/protobuf/**/*.proto"))
  puts "Cleaned"
end

desc "Compile spec/support protobuf definitions"
task :compile do
  ::Rake::Task["protobuf:compile"].invoke("", "spec/support/definitions", "spec/support/protobuf")
end
