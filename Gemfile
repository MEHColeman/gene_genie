source 'https://rubygems.org'

gemspec

# include local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
instance_eval(File.read(local_gemfile)) if File.readable?(local_gemfile)
