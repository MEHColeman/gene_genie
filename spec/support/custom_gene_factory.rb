require 'gene_genie/gene'

module GeneGenie
  class CustomGeneFactory
    def initialize(genes)
      @genes = genes
    end

    def create(_size)
      @genes
    end
  end
end
