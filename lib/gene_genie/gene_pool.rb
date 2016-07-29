require_relative 'gene_factory'
require_relative 'mutator/simple_gene_mutator'
require_relative 'mutator/null_mutator'
require_relative 'selector/coin_flip_selector'
require_relative 'template_evaluator'

module GeneGenie
  class GenePool
    def initialize(template:,
                   fitness_evaluator:,
                   gene_factory:,
                   size: 10,
                   mutator: NullMutator.new,
                   selector: CoinFlipSelector.new)
      unless (template.instance_of? Array) && (template[0].instance_of? Hash) then
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
    end

    # build a GenePool with a reasonable set of defaults.
    # You only need to specily the minimum no. of parameters
    def self.build(template, fitness_evaluator)
      unless (template.instance_of? Array) && (template[0].instance_of? Hash)
        fail ArgumentError, 'template must be an array of hashes of ranges'
      end
      gene_mutator = SimpleGeneMutator.new(template)
      gene_factory = GeneFactory.new(template, fitness_evaluator)

      template_evaluator = TemplateEvaluator.new(template)
      size = template_evaluator.recommended_size
      GenePool.new(template: template,
                   fitness_evaluator: fitness_evaluator,
                   gene_factory: gene_factory,
                   size: size,
                   mutator: gene_mutator)
    end

    def size
      @pool.size
    end

    def best
      @pool.max_by(&:fitness)
    end

    def best_fitness
      best.fitness
    end

    def best_ever
      @best_ever ||= best
    end

    def evolve
      old_best_fitness = best.fitness
      new_pool = []
      size.times do
        first_gene, second_gene = select_genes
        new_gene = combine_genes(first_gene, second_gene)
        new_pool << new_gene.mutate(@mutator)
      end
      @pool = new_pool

      check_best_ever
      best.fitness > old_best_fitness
    end

    def average_fitness
      total_fitness / @pool.size
    end

    def total_fitness
      fitness_values.reduce(:+)
    end

    def genes
      @pool
    end

    def worst
      @pool.min_by(&:fitness)
    end

    def worst_fitness
      worst.fitness
    end

    private

    def check_best_ever
      if best.fitness > best_ever.fitness
        @best_ever = best
      end
    end

    def select_genes
      @selector.call(self)
    end

    def combine_genes(first, second)
      first.combine(second)
    end

    def fitness_values
      @pool.map(&:fitness)
    end
  end
end
