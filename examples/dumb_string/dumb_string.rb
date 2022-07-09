require 'gene_genie'

# DumbStringyScorer takes the optimisation parameters as a representation of a
# string. The fitness is calculated as the sum of the squares of the distance
# between the target letter and the actual letter for each letter in the string.
class DumbStringyScorer
  def initialize(target)
    @target = target
  end

  def fitness(params)
    - ((params.first.map.with_index { |(_,v), i| ((v + 97) - @target[i].ord) ** 2}.inject(&:+)))
  end
end

# Stringy is used to convert the optimisation parameters into a string
class Stringy
  def initialize(hash_array)
    @stringy_hash = hash_array.first
  end

  def to_s
    @stringy_hash.map { |_, v| (v + 97).chr }.join
  end
end

#target = 'floccinaucinihilipihilification'
#target = 'abcdefghijklmnopqrstuvwxyz'
target = 'testing'
target.downcase!

# the template contains a list of the parameter to optimise and their range of
# values
template = {}
target.length.times { |i| template[i] = 0..25 }
template = [template]

# the fitness evaluator is any object that can respond to the fitness method
# with a float
fitness_evaluator = DumbStringyScorer.new(target)

genie = GeneGenie::Genie.new(template, fitness_evaluator)

genie.register_listener(Proc.new { |g| puts "#{Stringy.new(g.best.to_hashes).to_s} #{g.best.fitness}"})
genie.optimise

puts genie.best.inspect
puts Stringy.new(genie.best.to_hashes)
puts genie.best.fitness
