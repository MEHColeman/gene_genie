require_relative 'gene_factory'
require_relative 'mutator/simple_gene_mutator'
require_relative 'mutator/null_mutator'


module GeneGenie
  class GenePool
    def initialize(template, fitness_evaluator, gene_factory,
                   mutator = NullMutator.new)
      unless template.instance_of? Hash
        fail ArgumentError, 'template must be a hash of ranges'
      end
      unless fitness_evaluator.respond_to?(:fitness)
        fail ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator
      @mutator = mutator

      #size = template_evaluator.recommended_size
      size ||= 10
      @pool = gene_factory.create(size)
    end

    # build a GenePool with a reasonable set of defaults.
    # You only need to specily the minimum no. of parameters
    def self.build(template, fitness_evaluator)
      gene_mutator = SimpleGeneMutator.new(template)
      gene_factory = GeneFactory.new(template, fitness_evaluator)
      GenePool.new(template, fitness_evaluator, gene_factory,
                   gene_mutator)
    end

    def size
      @pool.size
    end

    def best
      @pool.max_by { |gene| gene.fitness }
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
      best.fitness > old_best_fitness
    end

    private
    # a very simple selection - pick by sorted order
    # pick two different genes
    def select_genes
      selectees = @pool.sort
      first, second = nil, nil
      probability =  [(( 1/size ) * 3), 0.8].max
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
  end
end
