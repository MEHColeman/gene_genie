require_relative 'gene_pool'

# Namespace for GeneGenie genetic algorithm optimisation gem
# @since 0.0.1
module GeneGenie

  # Top level, basic interface for GA optimisation.
  # Genie will attempt to optimise based on best-guess defaults if none are
  # provided
  # @since 0.0.1
  class Genie
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

      @best_fitness = @fitness_evaluator.fitness(best)

      best_fitness > previous_best
    end
    alias_method :optimize, :optimise

    def best
      @gene_pool.best.to_hash
    end

    def best_fitness
      @best_fitness ||= @gene_pool.best.fitness
    end
  end
end
