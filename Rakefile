require "bundler/gem_tasks"
require "chandler/tasks"
require "rake/testtask"
require "rubocop/rake_task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new

task "release:rubygem_push" => "chandler:push"
task :default => [:test, :rubocop]
