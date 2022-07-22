require_relative 'gene_pool'
require_relative 'listener/logging_listener'

# Namespace for GeneGenie genetic algorithm optimisation gem
# @since 0.0.1
module GeneGenie
  # Top level, basic interface for GA optimisation.
  # Genie will attempt to optimise based on best-guess defaults if none are
  # provided
  # Genie is basically a wrapper around GenePool that lets you get going as
  # quickly as possible by providing a reasonable set of defaults.
  # For more control and customisation, go straight to using GenePoo
  # @since 0.0.1
  class Genie
    DEFAULT_NO_OF_GENERATIONS = 50
    IMPROVEMENT_THRESHOLD = 0.1 # %

    def initialize(template, fitness_evaluator)
      @template = template
      @fitness_evaluator = fitness_evaluator
      @gene_pool = GenePool.build(template, fitness_evaluator)
    end

    # Optimise the genes until the convergence criteria are met.
    # A reasonable set of defaults for criteria will be applied.
    # @param [Integer] number_of_generations
    def optimise(number_of_generations = 0)
      previous_best = best_fitness

      # optimise
      if number_of_generations > 0
        evolve_n_times(number_of_generations)
      else
        optimise_by_strategy
      end

      @best_fitness = @fitness_evaluator.fitness(best)
      @best_fitness > previous_best
    end
    alias_method :optimize, :optimise

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

    def evolve_n_times(n)
      n.times { @gene_pool.evolve }
    end

    def optimise_by_strategy
      DEFAULT_NO_OF_GENERATIONS.times do
        @gene_pool.evolve
      end
      DEFAULT_NO_OF_GENERATIONS.times do
        current_fitness = best_fitness
        @gene_pool.evolve
        break if (best_fitness < current_fitness *
          (1 + (IMPROVEMENT_THRESHOLD / 100)) && best_fitness > 0)
      end
    end
  end
end
