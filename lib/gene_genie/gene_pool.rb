require_relative 'gene_factory'

module GeneGenie
  class GenePool
    def initialize(template, fitness_evaluator, gene_factory)
      #template_evaluator, gene_mutator, gene_factory)
      unless template.instance_of? Hash
        fail ArgumentError, 'template must be a hash of ranges'
      end
      unless fitness_evaluator.respond_to?(:fitness)
        fail ArgumentError, 'fitness_evaluator must respond to fitness'
      end

      @template = template
      @fitness_evaluator = fitness_evaluator

      #size = template_evaluator.recommended_size
      size ||= 10
      @pool = gene_factory.create(size)
    end

    def self.build(template, fitness_evaluator)
      #template_evaluator = TemplateEvaluator.new
      #gene_mutator = GeneMutator.new
      gene_factory = GeneFactory.new(template, fitness_evaluator)
      GenePool.new(template, fitness_evaluator, gene_factory)
      #template_evaluator, gene_mutator, gene_factory)
    end

    def size
      @pool.size
    end

    def best
      @pool.max_by { |gene| gene.fitness }
    end
  end
end
