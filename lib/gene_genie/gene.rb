require_relative 'combiner/one_point_combiner'

module GeneGenie
  # A Gene is the basic unit of the genetic algorithm. Genes hold the
  # information used to evaluate their fitness.
  # They are combined into new Genes during the optimisation process.
  # @since 0.0.1
  class Gene
    def initialize(information:,
                   fitness_evaluator:,
                   gene_combiner: GeneGenie::Combiner::OnePointCombiner.new)
      fail ArgumentError, 'information must be Array' unless information.kind_of? Array
      fail ArgumentError, 'information must be Array of Hashes' unless information[0].kind_of? Hash

      @information = information
      @fitness_evaluator = fitness_evaluator
      @combiner = gene_combiner
    end

    def to_hashes
      @information
    end

    def fitness
      @fitness ||= @fitness_evaluator.fitness(@information)
    end

    def fitness_evaluator
      @fitness_evaluator
    end

    def normalised_fitness(minimum)
      @normalised_fitness ||= fitness - minimum
    end

    def mutate(mutator)
      @information = mutator.call @information
      @fitness = nil
      @normalised_fitness = nil
      self
    end

    def combine(other_gene)
      @combiner.call(self, other_gene)
    end

    def <=>(other)
      fitness <=> other.fitness
    end
  end
end
