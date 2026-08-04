require 'gene_genie/combiner/one_point_combiner'
require 'gene_genie/gene'

require 'support/samples'

module GeneGenie
  module Combiner
    RSpec.describe OnePointCombiner do
      let(:information)        { [{ a: 10, b: 20 }, { c: 30, d: 40 }] }
      let(:second_information) { [{ a: 30, b: 40 }, { c: 70, d: 60 }] }

      let(:first_gene) do
        GeneGenie::Gene.new(information:,
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

          expect(new_gene_hashes[0][:a]).to eq(10).or eq(30)
          expect(new_gene_hashes[0][:b]).to eq(20).or eq(40)
          expect(new_gene_hashes[1][:c]).to eq(30).or eq(70)
          expect(new_gene_hashes[1][:d]).to eq(40).or eq(60)
        end

        it 'returns a Gene' do
          expect(subject.call(first_gene, second_gene)).to be_kind_of Gene
        end
      end
    end
  end
end
