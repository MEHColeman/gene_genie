module GeneGenie
  # A Gene is the basic unit of the genetic algorithm. Genes hold the
  # information used to evaluate their fitness.
  # They are combined into new Genes during the optimisation process.
  # @since 0.0.1
  class Gene
    def initialize(information, fitness_evaluator)
      fail ArgumentError, 'information must be Array' unless information.kind_of? Array
      fail ArgumentError, 'information must be Array of Hashes' unless information[0].kind_of? Hash

      @information = information
      @fitness_evaluator = fitness_evaluator
    end

    def to_hashes
      @information
    end

    def fitness
      @fitness ||= @fitness_evaluator.fitness(@information)
    end

    def mutate(mutator)
      @information = mutator.call @information
      @fitness = nil
      self
    end

    def combine(other_gene)
      other_gene_hash = other_gene.to_hashes
      new_information = @information.map.with_index do |part, index|
        new_hash = {}
        part.each do |k, v|
          new_hash[k] = (rand > 0.5) ? v : other_gene_hash[index][k]
        end
        new_hash
      end
      Gene.new(new_information, @fitness_evaluator)
    end

    def <=>(other)
      fitness <=> other.fitness
    end
  end
end
