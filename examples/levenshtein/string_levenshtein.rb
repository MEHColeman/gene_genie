require 'gene_genie'
require 'levenshtein-ffi'

# StringyScorer takes the optimisation parameters as a representation of a
# string. The fitness is calculated as the levenshtein distance between the
# target string and the actual string.
class StringyScorer
  def initialize(target)
    @target = target
  end

  def fitness(params)
    subject = Stringy.new(params).to_s
    - Levenshtein.distance(@target, subject)
  end
end

# Stringy represents the conversion of your optimisation parameters into a
# useful model. In this case the useful model is a string.
class Stringy
  def initialize(hash_array)
    @stringy_hash = hash_array.first
  end

  def to_s
    @stringy_hash.map { |_, v| (v +97).chr }.join
  end
end

#target = 'floccinaucinihilipilification'
#target = 'abcdefghijklmnoprstuvwxyz'
target = 'testing'
target.downcase!

# the template contains a list of the parameter to optimise and their range of
# values
template = {}
target.length.times { |i| template[i] = 0..25 }
template = [template]

# the fitness evaluator is any object that can respond to the fitness method
# with a float
fitness_evaluator = StringyScorer.new(target)

genie = GeneGenie::Genie.new(template, fitness_evaluator)

genie.register_listener(Proc.new { |g| puts "#{Stringy.new(g.best.to_hashes).to_s} #{g.best.fitness}"})
genie.optimise
puts genie.best.inspect
