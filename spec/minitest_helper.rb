require 'minitest'
require 'minitest/autorun'

require_relative 'support/samples'
require_relative 'support/fitness_evaluator_helper'

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # simplecov not installed. That's OK
end
