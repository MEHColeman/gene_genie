# frozen_string_literal: true

require_relative 'combiner/one_point_combiner'

module GeneGenie
  # A Gene is the basic unit of the genetic algorithm. Genes hold the
  # information used to evaluate their fitness.
  # They are combined into new Genes during the optimisation process.
  # @since 0.0.1
  class Gene
    attr_reader :fitness_evaluator

    def initialize(information:,
                   fitness_evaluator:,
                   gene_combiner: GeneGenie::Combiner::OnePointCombiner.new)
      raise ArgumentError, 'information must be Array' unless information.is_a? Array
      raise ArgumentError, 'information must be Array of Hashes' unless information[0].is_a? Hash

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

    # Fitness relative to a baseline - typically the worst fitness in the
    # pool. Not memoised, since the baseline changes from generation to
    # generation.
    def normalised_fitness(minimum)
      fitness - minimum
    end

    def mutate(mutator)
      @information = mutator.call @information
      @fitness = nil
      self
    end

    def combine(other_gene)
      @combiner.call(self, other_gene)
    end

    def <=>(other)
      fitness <=> other.fitness
    end

    # Genes are equal when they hold the same information. Note that genes
    # are mutable (see #mutate), so avoid using them as Hash keys across
    # mutations.
    def ==(other)
      other.is_a?(Gene) && to_hashes == other.to_hashes
    end
    alias eql? ==

    def hash
      @information.hash
    end

    def inspect
      "#<GeneGenie::Gene #{@information.inspect} fitness=#{@fitness.inspect}>"
    end
  end
end
