# frozen_string_literal: true

module GeneGenie
  module Mutator
    # A SimpleGeneMutator loops through each member of a hash, and has a
    # (mutation_rate) chance of swapping each value for another valid value,
    # based on the template.
    # @since 0.0.1
    class SimpleGeneMutator
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible mutation
      def initialize(template, mutation_rate = 0.01, random: Random.new)
        @template = template.is_a?(Hash) ? [template] : template
        @mutation_rate = mutation_rate
        @random = random
      end

      def call(information)
        information.each_with_index do |hash, index|
          hash.each_key do |key|
            next unless @random.rand < @mutation_rate

            hash[key] = sample(@template[index][key])
          end
        end
        information
      end

      private

      def sample(options)
        options.is_a?(Array) ? options.sample(random: @random) : @random.rand(options)
      end
    end
  end
end
