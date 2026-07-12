# frozen_string_literal: true

module GeneGenie
  # A NullMutator does no mutation on the gene
  # @since 0.0.1
  class NullMutator
    def initialize(*_); end

    def call(information)
      information
    end
  end
end
