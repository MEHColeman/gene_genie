# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', require: false
end

# include local gemfile
local_gemfile = File.join(__dir__, 'Gemfile.local')
instance_eval(File.read(local_gemfile)) if File.readable?(local_gemfile)
