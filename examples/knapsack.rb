# frozen_string_literal: true

require 'gene_genie'

# The classic 0/1 knapsack problem: choose which items to pack so that
# their total value is maximised without exceeding the weight capacity.
#
# Each item's allele is the array [0, 1] - packed or not - showing how a
# template can use arrays of choices rather than ranges.

ITEMS = {
  tent: { weight: 11, value: 9 },
  stove: { weight: 4, value: 7 },
  water: { weight: 7, value: 10 },
  first_aid: { weight: 3, value: 8 },
  camera: { weight: 5, value: 4 },
  rope: { weight: 6, value: 5 },
  torch: { weight: 2, value: 6 },
  food: { weight: 9, value: 10 },
  radio: { weight: 8, value: 3 },
  map: { weight: 1, value: 7 }
}.freeze

CAPACITY = 30

template = ITEMS.keys.to_h { |item| [item, [0, 1]] }

genie = GeneGenie::Genie.new(template, seed: 7) do |choices|
  weight = ITEMS.sum { |item, stats| choices[item] * stats[:weight] }
  value  = ITEMS.sum { |item, stats| choices[item] * stats[:value] }

  # Overweight packs are penalised in proportion to how overweight they are,
  # so evolution can climb back into the feasible region.
  weight > CAPACITY ? value - ((weight - CAPACITY) * 5) : value
end

result = genie.run(patience: 30)

packed = result.best.select { |_, packed_flag| packed_flag == 1 }.keys
weight = packed.sum { |item| ITEMS[item][:weight] }

puts "pack:   #{packed.join(', ')}"
puts "value:  #{result.best_fitness}"
puts "weight: #{weight}/#{CAPACITY}"

# to see this code in action:
# ruby -I ../lib knapsack.rb
