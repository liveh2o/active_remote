#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

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
task :compile, [] => :clean do 
  cmd = "rprotoc --ruby_out=spec/support/protobuf --proto_path=spec/support/definitions spec/support/definitions/*.proto"
  sh(cmd)
end
