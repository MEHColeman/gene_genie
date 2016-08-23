require 'minitest_helper'
require 'support/custom_gene_factory'
require 'gene_genie/selector/proportional_selector'
require 'gene_genie/gene'
require 'gene_genie/gene_pool'

module GeneGenie
  describe ProportionalSelector do
    let(:gene_one)   { Gene.new(information:[{a: 1, b:1}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:gene_two)   { Gene.new(information:[{a: 3, b:11}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:gene_three) { Gene.new(information:[{a: 6, b:11}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:pool) { GenePool.new( template: [{}],
                              fitness_evaluator: sample_fitness_evaluator,
                              gene_factory: CustomGeneFactory.new([ gene_one, gene_two, gene_three]),
                             )}

    subject { ProportionalSelector.new }

    describe '#call' do
      it 'selects two genes' do
        result = subject.call(pool)
        assert_equal 2, result.size
        assert_kind_of Gene, result.first
        assert_kind_of Gene, result.last
      end

      it 'selects genes in proportion to their fitness' do
        totals = Hash.new(0)
        5000.times do
          subject.call(pool).each { |gene| totals[gene] +=1 }
        end

        assert totals[gene_three] > totals[gene_two]
        assert totals[gene_two] > totals[gene_one]

        assert (totals[gene_three] - 6600).abs < 300, 'Proportions wrong'
        assert (totals[gene_two] - 3300).abs < 300, 'Proportions wrong'
        assert (totals[gene_one] - 100).abs < 300, 'Proportions wrong'
      end
    end
  end
end
