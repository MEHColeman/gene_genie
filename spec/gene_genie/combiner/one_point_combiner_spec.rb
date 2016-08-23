require 'minitest_helper'
require 'gene_genie/combiner/one_point_combiner'
require 'gene_genie/gene'

module GeneGenie
  module Combiner
    describe OnePointCombiner do
      let(:information)        { [{ a: 10, b: 20,}, { c: 30, d: 40 }] }
      let(:second_information) { [{ a: 30, b: 40 }, { c: 70, d: 60 }] }

      let(:first_gene)  { GeneGenie::Gene.new(information: information,
                                   fitness_evaluator: sample_fitness_evaluator) }
      let(:second_gene) { GeneGenie::Gene.new(information: second_information,
                                   fitness_evaluator: sample_fitness_evaluator) }

      subject { Combiner::OnePointCombiner.new }

      describe '#combine' do
        it 'combines information from the specified gene to create a new gene' do
          new_gene_hashes = subject.call(first_gene, second_gene).to_hashes

          assert new_gene_hashes[0][:a] == 10 || new_gene_hashes[0][:a] == 30
          assert new_gene_hashes[0][:b] == 20 || new_gene_hashes[0][:b] == 40
          assert new_gene_hashes[1][:c] == 30 || new_gene_hashes[1][:c] == 70
          assert new_gene_hashes[1][:d] == 40 || new_gene_hashes[1][:d] == 60
        end

        it 'returns a Gene' do
          assert_kind_of Gene, subject.call(first_gene, second_gene)
        end
      end
    end
  end
end

