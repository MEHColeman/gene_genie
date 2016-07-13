require_relative 'gene_factory'
require_relative 'mutator/simple_gene_mutator'
require_relative 'mutator/null_mutator'
require_relative 'template_evaluator'

module GeneGenie
  class GenePool
    def initialize(template, fitness_evaluator, gene_factory, size = 10,
                   mutator = NullMutator.new)
      unless (template.instance_of? Array) && (template[0].instance_of? Hash) then
        fail ArgumentError, 'template must be an array of hashes of ranges'
      end
      unless fitness_evaluator.respond_to?(:fitness)
        fail ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator
      @mutator = mutator

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
      GenePool.new(template, fitness_evaluator, gene_factory, size,
                   gene_mutator)
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
      fitness_values.reduce(:+) / @pool.size
    end

    private

    def check_best_ever
      if best.fitness > best_ever.fitness
        @best_ever = best
      end
    end

    # a very simple selection - pick by sorted order
    # pick two different genes
    def select_genes
      selectees = @pool.sort.reverse
      first, second = nil, nil
      probability = [((1.0 / size) * 3), 0.8].min
      while !first || !second do
        selectees.each do |s|
          if rand < probability
            selectees.delete(s)
            if !first
              first = s
              break
            else
              second = s
            end
          end
        end
      end
      [first, second]
    end

    def combine_genes(first, second)
      first.combine(second)
    end

    def fitness_values
      @pool.map(&:fitness)
    end
  end
end
