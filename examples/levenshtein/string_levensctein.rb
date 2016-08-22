require 'gene_genie'
require 'levenshtein-ffi'

class StringyScorer
  def initialize(target)
    @target = target
  end

  def fitness(params)
    subject = Stringy.new(params).to_s
    - Levenshtein.distance(@target, subject)
  end
end

class Stringy
  def initialize(hash_array)
    @stringy_hash = hash_array.first
  end

  def to_s
    @stringy_hash.map { |_, v| (v +97).chr }.join
  end
end

# the template contains a list of the parameter to optimise and their range of values
target = 'floccinaucinihilipilification'
target.downcase!

template = {}
target.length.times { |i| template[i] = 0..25 }
template = [template]

# the fitness evaluator is any object that can respond to the fitness method with a float
# in this case, it sums the values of the parameters.
# e.g. { a: 2, b: 42, c: 0, d: -14 } = 30
fitness_evaluator = StringyScorer.new(target)

genie = GeneGenie::Genie.new(template, fitness_evaluator)

genie.register_listener(Proc.new { |g| puts Stringy.new(g.best.to_hashes).to_s })
genie.optimise
# the best possible result is { a: 10, b: 100, c: 1, d: 5} = 116
puts genie.best.inspect
