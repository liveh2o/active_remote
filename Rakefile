# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

require "standard/rake"

task default: %i[spec standard:fix]

desc "Remove protobuf definitions that have been compiled"
task :clean do
  FileUtils.rm(Dir.glob("spec/support/protobuf/**/*.proto"))
  puts "Cleaned"
end

require "protobuf/tasks"

desc "Compile spec/support protobuf definitions"
task :compile do
  Rake::Task["protobuf:compile"].invoke("", "spec/support/definitions", "spec/support/protobuf")
end
