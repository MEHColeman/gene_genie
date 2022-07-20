require 'gene_genie'

class Summer
  def fitness(params)
    params.inject(0) {|acc, values| acc + values.each_value.inject(&:+)}
  end
end

# the template contains a list of the parameter to optimise and their range of values
template = [{
  a: 1..100,
  b: 5..1000,
  c: 0..1,
  d: -500..50
}]

# the fitness evaluator is any object that can respond to the fitness method with a float
# in this case, it sums the values of the parameters.
# e.g. { a: 2, b: 42, c: 0, d: -14 } = 30
fitness_evaluator = Summer.new

genie = GeneGenie::Genie.new(template, fitness_evaluator)

genie.register_listener(Proc.new do |g|
  puts "Best score: '#{g.best.to_hashes.to_s}', Score: #{g.best_fitness}"
end)

genie.optimise
# the best possible result is { a: 100, b: 1000, c: 1, d: 50} = 1151

puts genie.best.inspect

# to see this code in action:
# bundle exec ruby sum.rb
