require 'minitest_helper'
require 'support/custom_gene_factory'
require 'gene_genie/selector/coin_flip_selector'
require 'gene_genie/gene'
require 'gene_genie/gene_pool'

module GeneGenie
  describe CoinFlipSelector do
    let(:gene_one)   { Gene.new([{a: 2, b:4}], sample_fitness_evaluator) }
    let(:gene_two)   { Gene.new([{a: 6, b:5}], sample_fitness_evaluator) }
    let(:gene_three) { Gene.new([{a: 8, b:6}], sample_fitness_evaluator) }
    let(:pool) { GenePool.new( template: [{}],
                              fitness_evaluator: sample_fitness_evaluator,
                              gene_factory: CustomGeneFactory.new([ gene_one, gene_two, gene_three]),
                             )}

    subject { CoinFlipSelector.new }

    describe '#call' do
      it 'selects two genes' do
        result = subject.call(pool)
        assert_equal 2, result.size
        assert_kind_of Gene, result.first
        assert_kind_of Gene, result.last
      end

      it 'selects the best genes more often, eventually' do
        totals = Hash.new(0)
        1000.times do
          subject.call(pool).each { |gene| totals[gene] +=1 }
        end

        assert totals[gene_three] > totals[gene_two]
        assert totals[gene_two] > totals[gene_one]
      end
    end
  end
end
