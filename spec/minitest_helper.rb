require 'minitest'
require 'minitest/autorun'

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # simplecov not installed. That's OK
end
