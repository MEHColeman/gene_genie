module GeneGenie
  # A Gene is the basic unit of the genetic algorithm. Genes hold the
  # information used to evaluate their fitness.
  # They are combined into new Genes during the optimisation process.
  # @since 0.0.1
  class Gene
    def initialize(information, fitness_evaluator)
      @information = information
      @fitness_evaluator = fitness_evaluator
    end

    def to_hash
      @information
    end

    def fitness
      @fitness ||= @fitness_evaluator.fitness(@information)
    end

    def mutate(mutator)
      @information = mutator.call @information
    end

    def <=>(gene)
      fitness <=> gene.fitness
    end
  end
end
