require "bundler/gem_tasks"

desc 'Run a bunch of code metrics'
task :check do
  simplecov
  exec 'bundle exec sandi_meter -g'
  excellent
  cane
  metric_fu
end

require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end
