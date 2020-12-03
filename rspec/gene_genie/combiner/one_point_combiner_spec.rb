require 'gene_genie/combiner/one_point_combiner'
require 'gene_genie/gene'

require 'support/samples'

module GeneGenie
  module Combiner
    RSpec.describe OnePointCombiner do
      let(:information)        { [{ a: 10, b: 20 }, { c: 30, d: 40 }] }
      let(:second_information) { [{ a: 30, b: 40 }, { c: 70, d: 60 }] }

      let(:first_gene) do
        GeneGenie::Gene.new(information: information,
                            fitness_evaluator: sample_fitness_evaluator)
      end
      let(:second_gene) do
        GeneGenie::Gene.new(information: second_information,
                            fitness_evaluator: sample_fitness_evaluator)
      end

      subject { Combiner::OnePointCombiner.new }

      describe '#combine' do
        it 'combines information from the specified gene to create a new gene' do
          new_gene_hashes = subject.call(first_gene, second_gene).to_hashes

          expect(new_gene_hashes[0][:a] == 10 || new_gene_hashes[0][:a] == 30).to be true
          expect(new_gene_hashes[0][:b] == 20 || new_gene_hashes[0][:b] == 40).to be true
          expect(new_gene_hashes[1][:c] == 30 || new_gene_hashes[1][:c] == 70).to be true
          expect(new_gene_hashes[1][:d] == 40 || new_gene_hashes[1][:d] == 60).to be true
        end

        it 'returns a Gene' do
          expect(subject.call(first_gene, second_gene)).to be_kind_of Gene
        end
      end
    end
  end
end
