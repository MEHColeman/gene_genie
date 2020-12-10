require 'gene_genie/selector/coin_flip_selector'
require 'gene_genie/gene'
require 'gene_genie/gene_pool'

require 'support/custom_gene_factory'
require 'support/samples'

module GeneGenie
  RSpec.describe CoinFlipSelector do
    let(:gene_one)   { Gene.new(information: [{a: 2, b:4}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:gene_two)   { Gene.new(information: [{a: 6, b:5}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:gene_three) { Gene.new(information: [{a: 8, b:6}],
                                fitness_evaluator: sample_fitness_evaluator) }
    let(:pool) { GenePool.new( template: [{}],
                              fitness_evaluator: sample_fitness_evaluator,
                              gene_factory: CustomGeneFactory.new([ gene_one, gene_two, gene_three]),
                             )}

    subject { CoinFlipSelector.new }

    describe '#call' do
      it 'selects two genes' do
        result = subject.call(pool)
        expect(result.size).to eq 2
        expect(result.first).to be_kind_of Gene
        expect(result.last).to be_kind_of Gene
      end

      it 'selects the best genes more often, eventually' do
        totals = Hash.new(0)
        1000.times do
          subject.call(pool).each { |gene| totals[gene] +=1 }
        end

        expect(totals[gene_three]).to be > totals[gene_two]
        expect(totals[gene_two]).to be > totals[gene_one]
      end
    end
  end
end
