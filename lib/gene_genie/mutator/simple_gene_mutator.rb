# frozen_string_literal: true

module GeneGenie
  # A SimpleGeneMutator loops through each member of a hash, and has a
  # (mutation_rate) chance of swapping each value for another valid value,
  # based on the template.
  # @since 0.0.1
  class SimpleGeneMutator
    # @param random [Random] source of randomness - pass a seeded instance
    #   for reproducible mutation
    def initialize(template, mutation_rate = 0.01, random: Random.new)
      @template = template
      @mutation_rate = mutation_rate
      @random = random
    end

    def call(information)
      information.each_with_index do |hash, index|
        hash.each_key do |key|
          next unless @random.rand < @mutation_rate

          hash[key] = @random.rand(@template[index][key])
        end
      end
      information
    end
  end
end
