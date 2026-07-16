require 'gene_genie/selector/tournament_selector'
require 'gene_genie/gene'
require 'gene_genie/gene_pool'

require 'support/custom_gene_factory'
require 'support/samples'

module GeneGenie
  RSpec.describe Selector::TournamentSelector do
    let(:gene_one) do
      Gene.new(information: [{ a: 1, b: 1 }],
               fitness_evaluator: sample_fitness_evaluator)
    end
    let(:gene_two) do
      Gene.new(information: [{ a: 3, b: 11 }],
               fitness_evaluator: sample_fitness_evaluator)
    end
    let(:gene_three) do
      Gene.new(information: [{ a: 6, b: 11 }],
               fitness_evaluator: sample_fitness_evaluator)
    end
    let(:pool) do
      GenePool.new(
        template: [{}],
        fitness_evaluator: sample_fitness_evaluator,
        gene_factory: CustomGeneFactory.new([gene_one, gene_two, gene_three])
      )
    end

    subject { Selector::TournamentSelector.new(random: Random.new(42)) }

    describe '#call' do
      it 'selects two genes' do
        result = subject.call(pool)

        expect(result.size).to eq 2
        expect(result.first).to be_kind_of Gene
        expect(result.last).to be_kind_of Gene
      end

      it 'selects fitter genes more often' do
        totals = Hash.new(0)
        500.times do
          subject.call(pool).each { |gene| totals[gene] += 1 }
        end

        expect(totals[gene_three]).to be > totals[gene_two]
        expect(totals[gene_two]).to be > totals[gene_one]
      end

      it 'still works when the pool has the same fitness everywhere' do
        equal_genes = Array.new(3) do |i|
          Gene.new(information: [{ a: i + 1, b: 0 }],
                   fitness_evaluator: sample_fitness_evaluator)
        end
        plateau_pool = GenePool.new(
          template: [{}],
          fitness_evaluator: sample_fitness_evaluator,
          gene_factory: CustomGeneFactory.new(equal_genes)
        )

        result = subject.call(plateau_pool)

        expect(result.size).to eq 2
      end
    end
  end
end
