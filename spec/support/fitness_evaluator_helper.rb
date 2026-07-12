module GeneGenie
  class TailoredFitnessEvaluator
    attr_writer :fitness

    def initialize(fitness)
      @fitness = fitness
    end

    def fitness(_)
      @fitness
    end
  end
end
