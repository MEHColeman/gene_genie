# frozen_string_literal: true

require_relative 'gene_factory'
require_relative 'mutator/nudge_mutator'
require_relative 'mutator/null_mutator'
require_relative 'selector/proportional_selector'
require_relative 'template_evaluator'

module GeneGenie
  # A GenePool holds the population of genes and evolves it generation by
  # generation through selection, combination (crossover) and mutation.
  # The fittest genes are carried into the next generation unchanged
  # (elitism), and the best gene ever seen is remembered even if later
  # generations regress.
  class GenePool
    attr_reader :generation

    def initialize(template:,
                   fitness_evaluator:,
                   gene_factory:,
                   size: 10,
                   mutator: Mutator::NullMutator.new,
                   selector: Selector::ProportionalSelector.new,
                   elitism: 1)
      template = [template] if template.is_a?(Hash)
      self.class.validate_template!(template)
      unless fitness_evaluator.respond_to?(:fitness)
        raise ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator
      @mutator = mutator
      @selector = selector
      @elitism = elitism
      @pool = gene_factory.create(size)
      @generation = 0
      @listeners = []
    end

    # build a GenePool with a reasonable set of defaults.
    # You only need to specify the minimum no. of parameters; any component
    # you don't supply is built for you.
    # @param random [Random] source of randomness for the pool's components -
    #   pass a seeded instance for a reproducible run
    # @param size [Integer, nil] population size (default: recommended for
    #   the template)
    # @param mutator [#call, nil] gene mutator (default: NudgeMutator)
    # @param selector [#call, nil] parent selector (default:
    #   ProportionalSelector)
    # @param combiner [#call, nil] gene combiner (default: OnePointCombiner)
    # @param elitism [Integer] top genes carried over unchanged each
    #   generation
    def self.build(template, fitness_evaluator, random: Random.new, size: nil,
                   mutator: nil, selector: nil, combiner: nil, elitism: 1)
      template = [template] if template.is_a?(Hash)
      validate_template!(template)
      mutator ||= Mutator::NudgeMutator.new(template, random:)
      combiner ||= Combiner::OnePointCombiner.new(random:)
      selector ||= Selector::ProportionalSelector.new(random:)
      gene_factory = GeneFactory.new(template, fitness_evaluator, combiner, random:)
      size ||= TemplateEvaluator.new(template).recommended_size

      GenePool.new(template:,
                   fitness_evaluator:,
                   gene_factory:,
                   size:,
                   mutator:,
                   selector:,
                   elitism:)
    end

    def self.validate_template!(template)
      return if template.is_a?(Array) && !template.empty? &&
                template.all? { |part| part.is_a?(Hash) }

      raise ArgumentError, 'template must be an array of hashes of ranges'
    end

    def register_listener(listener)
      @listeners << listener
    end

    def unregister_listener(listener)
      @listeners.delete(listener)
    end

    def size
      @pool.size
    end

    def best
      @best ||= @pool.max_by(&:fitness)
    end

    def best_fitness
      best.fitness
    end

    def worst
      @worst ||= @pool.min_by(&:fitness)
    end

    def worst_fitness
      worst.fitness
    end

    def best_ever
      @best_ever ||= best
    end

    # Replace the pool with a new generation: the top `elitism` genes are
    # carried over unchanged, the rest are bred by selection, combination
    # and mutation.
    # @return [Boolean] whether the best gene in the pool improved
    def evolve
      previous_best_ever = best_ever
      old_best_fitness = best.fitness

      elites = @elitism.positive? ? @pool.max_by(@elitism, &:fitness) : []
      offspring_count = size - elites.size
      @pool = elites + Array.new(offspring_count) { select_genes_combine_and_mutate }

      update_stats(previous_best_ever)
      @generation += 1

      @listeners.each { |l| l.call(self) }

      best.fitness > old_best_fitness
    end

    def average_fitness
      @average_fitness ||= total_fitness.fdiv(@pool.size)
    end

    def total_fitness
      @total_fitness ||= fitness_values.reduce(:+)
    end

    def total_normalised_fitness
      @total_normalised_fitness ||= normalised_fitness_values.reduce(:+)
    end

    def genes
      @pool
    end

    private

    def update_stats(previous_best_ever)
      @best = nil
      @worst = nil
      @total_fitness = nil
      @total_normalised_fitness = nil
      @average_fitness = nil

      @best_ever = best if best.fitness > previous_best_ever.fitness
    end

    def select_genes
      @selector.call(self)
    end

    def fitness_values
      @pool.map(&:fitness)
    end

    def normalised_fitness_values
      @pool.map { |gene| gene.normalised_fitness(worst_fitness) }
    end

    def select_genes_combine_and_mutate
      first_gene, second_gene = select_genes
      new_gene = first_gene.combine(second_gene)
      new_gene.mutate(@mutator)
    end
  end
end
