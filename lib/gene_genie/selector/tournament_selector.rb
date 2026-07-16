# frozen_string_literal: true

module GeneGenie
  module Selector
    # Tournament selection: for each parent, +tournament_size+ genes are
    # drawn at random (with replacement) and the fittest of them wins.
    # Larger tournaments increase selection pressure. Robust on fitness
    # plateaus and insensitive to the scale of fitness values, which makes
    # it a good general-purpose choice.
    # @since 0.4.0
    class TournamentSelector
      # @param tournament_size [Integer] how many genes enter each tournament
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible selection
      def initialize(tournament_size: 3, random: Random.new)
        @tournament_size = tournament_size
        @random = random
      end

      # @param pool [GenePool] the pool of genes; must respond to +genes+
      # @return [Array<Gene>] an array containing two selected genes
      def call(pool)
        [pick_one(pool.genes), pick_one(pool.genes)]
      end

      private

      def pick_one(genes)
        contenders = Array.new([@tournament_size, genes.size].min) do
          genes[@random.rand(genes.size)]
        end
        contenders.max_by(&:fitness)
      end
    end
  end
end
