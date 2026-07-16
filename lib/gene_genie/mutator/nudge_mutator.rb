# frozen_string_literal: true

module GeneGenie
  module Mutator
    # A NudgeMutator is very similar to a SimpleGeneMutator, except that it
    # will only change a value by a small amount, rather than to any valid
    # value. So an allele with a range specified in the template of 1..100
    # and a current value of 50 might change within 45..55 instead of
    # 1..100.
    # Works with integer ranges, float ranges (continuous nudges) and
    # arrays of options (nudges move to a nearby position in the list).
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

      def nudge(options, value)
        options.is_a?(Array) ? nudge_within_list(options, value) : nudge_within_range(options, value)
      end

      def nudge_within_list(list, value)
        reach = (list.size * @nudge_fraction).ceil
        index = list.index(value) || @random.rand(list.size)
        lower = [0, index - reach].max
        upper = [list.size - 1, index + reach].min
        list[@random.rand(lower..upper)]
      end

      def nudge_within_range(range, value)
        lower, upper = if float_range?(range)
                         reach = (range.end - range.begin) * @nudge_fraction
                         [[range.begin, value - reach].max, [range.end, value + reach].min]
                       else
                         reach = (range.size * @nudge_fraction).ceil
                         [[range.min, value - reach].max, [range.max, value + reach].min]
                       end
        @random.rand(lower..upper)
      end

      def float_range?(range)
        range.begin.is_a?(Float) || range.end.is_a?(Float)
      end
    end
  end
end
