#!/usr/bin/env rake
require "bundler/gem_tasks"
require "protobuf/tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

desc "Run cops"
::RuboCop::RakeTask.new(:rubocop)

desc "Run specs"
::RSpec::Core::RakeTask.new(:spec)

desc "Run cops and specs (default)"
task :default => [:rubocop, :spec]

desc "Remove protobuf definitions that have been compiled"
task :clean do
  FileUtils.rm(Dir.glob("spec/support/protobuf/**/*.proto"))
  puts "Cleaned"
end

desc "Compile spec/support protobuf definitions"
task :compile do
  ::Rake::Task["protobuf:compile"].invoke("", "spec/support/definitions", "spec/support/protobuf")
end
