require 'rake/testtask'
require 'fileutils'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

namespace :api do
  desc "Fetch APIs"
  task :fetch do
    FileUtils.mkdir_p("./fetched")
    sh("lib/misty_builder/tool.rb fetch")
  end

  desc "Diff APIs"
  task :diff do
    sh("lib/misty_builder/tool.rb compare")
  end
end
