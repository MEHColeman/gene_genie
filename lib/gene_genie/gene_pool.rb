require_relative 'gene_factory'
require_relative 'mutator/nudge_mutator'
require_relative 'mutator/null_mutator'
require_relative 'selector/proportional_selector'
require_relative 'template_evaluator'

module GeneGenie
  class GenePool
    def initialize(template:,
                   fitness_evaluator:,
                   gene_factory:,
                   size: 10,
                   mutator: NullMutator.new,
                   selector: ProportionalSelector.new)
      unless (template.instance_of? Array) && (template[0].instance_of? Hash)
        fail ArgumentError, 'template must be an array of hashes of ranges'
      end
      unless fitness_evaluator.respond_to?(:fitness)
        fail ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator
      @mutator = mutator
      @selector = selector
      @pool = gene_factory.create(size)
      @generation = 0
      @listeners = []
    end

    # build a GenePool with a reasonable set of defaults.
    # You only need to specily the minimum no. of parameters
    def self.build(template, fitness_evaluator)
      unless (template.instance_of? Array) && (template[0].instance_of? Hash)
        fail ArgumentError, 'template must be an array of hashes of ranges'
      end
      gene_mutator = NudgeMutator.new(template, 0.01)
      gene_factory = GeneFactory.new(template, fitness_evaluator)

      template_evaluator = TemplateEvaluator.new(template)
      size = template_evaluator.recommended_size
      GenePool.new(template: template,
                   fitness_evaluator: fitness_evaluator,
                   gene_factory: gene_factory,
                   size: size,
                   mutator: gene_mutator)
    end

    def register_listener(listener)
      @listeners << listener
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

    def evolve
      old_best_fitness = best.fitness
      new_pool = []
      size.times do
        new_pool << select_genes_combine_and_mutate
      end
      @pool = new_pool
      update_stats
      @generation += 1

      @listeners.each { |l| l.call(self) }

      best.fitness > old_best_fitness
    end

    def generation
      @generation
    end

    def average_fitness
      @average_fitness ||= total_fitness / @pool.size
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

    def update_stats
      @best = nil
      @worst = nil
      @total_fitness = nil
      @total_normalised_fitness = nil
      @average_fitness = nil

      @best_ever = best if best.fitness > best_ever.fitness
    end

    def select_genes
      @selector.call(self)
    end

    def fitness_values
      @pool.map(&:fitness)
    end

    def normalised_fitness_values
      @pool.map{ |gene| gene.normalised_fitness(worst_fitness) }
    end

    def select_genes_combine_and_mutate
      first_gene, second_gene = select_genes
      new_gene = first_gene.combine(second_gene)
      new_gene.mutate(@mutator)
    end
  end
end
