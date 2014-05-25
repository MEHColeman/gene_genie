# Namespace for GeneGenie genetic algorithm optimisation gem
# @since 0.0.1
module GeneGenie

  # Top level, basic interface for GA optimisation.
  # Genie will attempt to optimise based on best-guess defaults if non are provided
  # @since 0.0.1
  class Genie
    def initialize(template, fitness_evaluator)
      @template = template
      @fitness_evaluator = fitness_evaluator

    end

    # Optimise the genes until the convergence criteria are met.
    # A reasonable set of defaults for criteria will be applied.
    # @param [Integer] number_of_generations
    def optimise(number_of_generations = 0)
      true
    end

    def best
      Gene.new
    end
  end
end
