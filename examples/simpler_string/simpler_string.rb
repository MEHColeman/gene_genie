require 'gene_genie'

# SimplerStringyScorer is actually a more useful fitness than the levenshein distance
# It takes the optimisation parameters as a representation of a
# string. The fitness is calculated as:
# * the sum of the squares of the distance between the target letter and the
#   actual letter for each letter in the string.
# * plus the sum of the cubes of (200 - the distance between target and actual
#   cubed), up to a value of 200
# * plus a bonus 400 score if the letter is exactly correct.
# .... I mean... it did start of as simple than levenshtein, and then I got a
# bit carried away trying to tweak it.
# As it happens, the DumbStringyScorer seeems to perform the best anyway, at
# least for reasonably-sized strings
class SimplerStringyScorer
  def initialize(target)
    @target = target
  end

  def fitness(params)
    - ((params.first.map.with_index { |(_,v), i| ((v + 97) - @target[i].ord) ** 2}.inject(&:+))) +
      ((params.first.map.with_index { |(_,v), i| [(200-(((v + 97) - @target[i].ord) ** 3).abs),0].max}.inject(&:+))) +
      (params.first.map.with_index { |(_,v), i| ((v + 97) == @target[i].ord)}.count{|a| a} * 400 )
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

#target = 'floccinaucinihilipilification'
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
fitness_evaluator = SimplerStringyScorer.new(target)

genie = GeneGenie::Genie.new(template, fitness_evaluator)

genie.register_listener(Proc.new { |g| puts "#{Stringy.new(g.best.to_hashes).to_s} #{g.best_fitness}"})
genie.optimise
puts genie.best.inspect
