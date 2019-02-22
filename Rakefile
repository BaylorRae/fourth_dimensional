require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "sdoc"
require "rdoc/task"

RSpec::Core::RakeTask.new(:spec)

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--format=sdoc'
  rdoc.main = 'README.md'
end

task :default => [:spec, :rdoc]
