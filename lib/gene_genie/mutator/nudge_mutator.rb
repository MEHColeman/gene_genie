# frozen_string_literal: true

module GeneGenie
  # A NudgeMutator is very similar to a SimpleGeneMutator, except that it
  # will only change a value by a small amount, rather than to any valid
  # value. So an allele with a range specified in the template of 1..100 and
  # a current value of 50 might change within 45..55 instead of 1..100.
  # @since 0.2.0
  class NudgeMutator
    # @param template [Array<Hash>] the template the genes conform to
    # @param mutation_rate [Float] the chance of each allele being nudged
    # @param nudge_fraction [Float] the maximum size of a nudge, as a
    #   fraction of the allele's full range
    # @param random [Random] source of randomness - pass a seeded instance
    #   for reproducible mutation
    def initialize(template, mutation_rate = 0.04, nudge_fraction: 0.05, random: Random.new)
      @template = template
      @mutation_rate = mutation_rate
      @nudge_fraction = nudge_fraction
      @random = random
    end

    def call(information)
      information.each_with_index do |hash, index|
        hash.each_key do |key|
          next unless @random.rand < @mutation_rate

          hash[key] = nudge(@template[index][key], hash[key])
        end
      end
      information
    end

    private

    def nudge(range, value)
      nudge_max = (range.size * @nudge_fraction).ceil
      lower = [range.min, value - nudge_max].max
      upper = [range.max, value + nudge_max].min
      @random.rand(lower..upper)
    end
  end
end
