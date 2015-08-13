module GeneGenie
  class TailoredFitnessEvaluator
    def initialize(fitness)
      @fitness = fitness
    end

    def fitness(_)
      @fitness
    end

    def set_fitness(fitness)
      @fitness = fitness
    end
  end
end
