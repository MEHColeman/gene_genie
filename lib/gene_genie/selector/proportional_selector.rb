# frozen_string_literal: true

module GeneGenie
  # ProportionalSelector selects genes with probability proportional to
  # their normalised fitness (fitness minus the worst fitness in the pool) -
  # classic roulette-wheel selection.
  # When every gene in the pool has the same fitness there is nothing to be
  # proportional to, so selection falls back to picking uniformly at random.
  class ProportionalSelector
    # @param random [Random] source of randomness - pass a seeded instance
    #   for reproducible selection
    def initialize(random: Random.new)
      @random = random
    end

    # Selects two genes from a pool of genes.
    #
    # @param pool [GenePool] the pool of genes; must respond to +genes+ and
    #   +worst_fitness+
    # @return [Array<Gene>] an array containing two selected genes
    def call(pool)
      [pick_one(pool), pick_one(pool)]
    end

    private

    def pick_one(pool)
      genes = pool.genes
      cumulative = cumulative_fitnesses(pool)
      total = cumulative.last
      return genes[@random.rand(genes.size)] if total <= 0

      target = @random.rand * total
      genes[cumulative.bsearch_index { |sum| sum > target }]
    end

    # Cumulative normalised fitnesses, cached per generation. The pool
    # replaces its genes array wholesale on each evolution, so the array's
    # identity is a safe cache key.
    def cumulative_fitnesses(pool)
      genes = pool.genes
      return @cumulative if genes.equal?(@cached_genes)

      worst = pool.worst_fitness
      sum = 0.0
      @cumulative = genes.map { |gene| sum += gene.normalised_fitness(worst) }
      @cached_genes = genes
      @cumulative
    end
  end
end
