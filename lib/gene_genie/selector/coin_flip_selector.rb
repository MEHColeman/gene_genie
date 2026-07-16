# frozen_string_literal: true

module GeneGenie
  module Selector
    # A simple rank-based gene selection algorithm.
    # Genes are ordered by fitness, best first, and a loaded coin is flipped
    # for each gene in turn - the first gene to flip heads is selected,
    # wrapping around to the top of the list if none does. The coin is
    # loaded so that there is a reasonable spread throughout the gene
    # population, but the better the gene, the more likely it is to be
    # picked.
    # The two selected genes are distinct whenever the pool holds more than
    # one gene.
    class CoinFlipSelector
      # @param random [Random] source of randomness - pass a seeded instance
      #   for reproducible selection
      def initialize(random: Random.new)
        @random = random
      end

      # @param pool [GenePool] the pool of genes; must respond to +genes+
      # @return [Array<Gene>] an array containing two selected genes
      def call(pool)
        ranked = pool.genes.sort_by { |gene| -gene.fitness }
        first = pick(ranked)
        remaining = ranked.reject { |gene| gene.equal?(first) }
        second = remaining.empty? ? first : pick(remaining)
        [first, second]
      end

      private

      def pick(ranked)
        probability = [3.0 / ranked.size, 0.8].min
        loop do
          ranked.each { |gene| return gene if @random.rand < probability }
        end
      end
    end
  end
end
