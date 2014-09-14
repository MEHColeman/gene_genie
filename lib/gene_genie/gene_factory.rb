require_relative 'gene'

module GeneGenie
  # GeneFactory
  # This is a helper class that will create a specified number of genes, given
  # a template.
  # The default implementation will produce random genes, but other approaches
  # could be taken.
  class GeneFactory
    def initialize(template)
      @template = template
    end

    def create(size = 1)
      genes = []
      size.times do
        hash = create_hash_from_template
        genes << Gene.new(hash)
      end

      genes
    end

    private

    def create_hash_from_template
      new_hash = {}
      @template.each do |k, v|
        new_hash[k] = rand(v)
      end

      new_hash
    end
  end
end
