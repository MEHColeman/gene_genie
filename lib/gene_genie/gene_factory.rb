require_relative 'gene'

module GeneGenie
  # GeneFactory
  # This is a helper class that will create a specified number of genes, given
  # a template.
  # The default implementation will produce random genes, but other approaches
  # could be taken.
  class GeneFactory
    def initialize(template, fitness_evaluator)
      @template = template
      @fitness_evaluator = fitness_evaluator
    end

    def create(size = 1)
      genes = []
      size.times do
        genes << create_gene_from_template
      end
      genes
    end

    private

    def create_gene_from_template
      gene_array = @template.map do |part|
        create_hash_from_template_part(part)
      end
      Gene.new(gene_array, @fitness_evaluator)
    end

    def create_hash_from_template_part(part)
      new_hash = {}
      part.each do |k, v|
        new_hash[k] = rand(v)
      end
      new_hash
    end
  end
end
