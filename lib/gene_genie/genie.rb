# frozen_string_literal: true

require_relative 'gene_pool'
require_relative 'listener/logging_listener'

# Namespace for GeneGenie genetic algorithm optimisation gem
# @since 0.0.1
module GeneGenie
  # Top level, basic interface for GA optimisation.
  # Genie will attempt to optimise based on best-guess defaults if none are
  # provided.
  # Genie is basically a wrapper around GenePool that lets you get going as
  # quickly as possible by providing a reasonable set of defaults.
  # For more control and customisation, go straight to using GenePool.
  # @since 0.0.1
  class Genie
    # Used when no number of generations is given to #optimise: evolve at
    # most DEFAULT_MAX_GENERATIONS generations, stopping early once the best
    # fitness has not improved for STAGNATION_PATIENCE consecutive
    # generations.
    DEFAULT_MAX_GENERATIONS = 100
    STAGNATION_PATIENCE = 15

    attr_reader :gene_pool

    # @param template [Array<Hash>] the variables to optimise, with their
    #   ranges of possible values
    # @param fitness_evaluator [#fitness] scores a set of values
    # @param seed [Integer, nil] seed for the random number generator - pass
    #   a value to make the optimisation run reproducible
    def initialize(template, fitness_evaluator, seed: nil)
      @fitness_evaluator = fitness_evaluator
      random = seed.nil? ? Random.new : Random.new(seed)
      @gene_pool = GenePool.build(template, fitness_evaluator, random:)
    end

    # Optimise the genes.
    # @param number_of_generations [Integer] evolve exactly this many
    #   generations. With the default of 0, evolve until the best fitness
    #   stagnates (see STAGNATION_PATIENCE) or DEFAULT_MAX_GENERATIONS is
    #   reached.
    # @return [Boolean] whether the best fitness improved
    def optimise(number_of_generations = 0)
      previous_best = best_fitness

      if number_of_generations.positive?
        number_of_generations.times { @gene_pool.evolve }
      else
        optimise_until_stagnation
      end

      best_fitness > previous_best
    end
    alias optimize optimise

    def register_listener(listener)
      @gene_pool.register_listener(listener)
    end

    def best
      @gene_pool.best_ever.to_hashes
    end

    def best_fitness
      @gene_pool.best_ever.fitness
    end

    private

    def optimise_until_stagnation
      stagnant_generations = 0
      DEFAULT_MAX_GENERATIONS.times do
        previous = best_fitness
        @gene_pool.evolve
        stagnant_generations = best_fitness > previous ? 0 : stagnant_generations + 1
        break if stagnant_generations >= STAGNATION_PATIENCE
      end
    end
  end
end
