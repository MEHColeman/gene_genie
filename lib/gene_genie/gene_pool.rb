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
  end
end
