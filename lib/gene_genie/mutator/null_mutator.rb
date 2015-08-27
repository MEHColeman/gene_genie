module GeneGenie
  # A NullMutator does no mutation on the gene
  # @since 0.0.1
  class NullMutator
    def initialize(*_)
    end

    def call(hash)
      hash
    end
  end
end
