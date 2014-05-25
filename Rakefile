#require 'bundler/gem_tasks'
require 'rake/testtask'
require_relative 'spec/minitest_helper'

Rake::TestTask.new do |t|
  t.libs = ['lib','spec']
  t.warning = true
  t.pattern = "spec/**/*_spec.rb"
end
