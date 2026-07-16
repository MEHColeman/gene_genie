# frozen_string_literal: true

require 'gene_genie'

# Minimise a smooth two-dimensional function of floats:
#   f(x, y) = (x - 2.37)^2 + (y + 1.2)^2
# The optimum is x = 2.37, y = -1.2, where f = 0.
#
# This example shows off a few 0.4.0 features:
# - float ranges in the template
# - a bare Hash template (no wrapping array needed)
# - the fitness function supplied as a block
# - direction: :minimise
# - a seeded, reproducible run
# - Genie#run returning a Result with history and stats

template = { x: -10.0..10.0, y: -10.0..10.0 }

genie = GeneGenie::Genie.new(template, seed: 42, direction: :minimise) do |params|
  ((params[:x] - 2.37)**2) + ((params[:y] + 1.2)**2)
end

result = genie.run(patience: 25, max_generations: 500)

puts "best:        #{result.best.inspect}"
puts "fitness:     #{result.best_fitness}"
puts "generations: #{result.generations}"
puts "evaluations: #{result.evaluations}"
puts format('elapsed:     %.3fs', result.elapsed)

# to see this code in action:
# ruby -I ../lib float_optimisation.rb
