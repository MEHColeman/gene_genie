require_relative 'gene_factory'

module GeneGenie
  class GenePool
    def initialize(template, fitness_evaluator, gene_factory)
      unless template.instance_of? Hash
        fail ArgumentError, 'template must be a hash of ranges'
      end
      unless fitness_evaluator.respond_to?(:fitness)
        fail ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator

      size ||= 10
      @pool = gene_factory.create(size)
    end

    def self.build(template, fitness_evaluator)
      gene_factory = GeneFactory.new(template, fitness_evaluator)
      GenePool.new(template, fitness_evaluator, gene_factory)
    end

    def size
      @pool.size
    end
  end
end
