require 'gene_genie/selector/proportional_selector'
require 'gene_genie/gene'
require 'gene_genie/gene_pool'

require 'support/custom_gene_factory'
require 'support/samples'

module GeneGenie
  RSpec.describe ProportionalSelector do
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

    subject { ProportionalSelector.new }

    describe '#call' do
      it 'selects two genes' do
        result = subject.call(pool)
        expect(result.size).to eq 2
        expect(result.first).to be_kind_of Gene
        expect(result.last).to be_kind_of Gene
      end

      it 'selects genes in proportion to their fitness' do
        totals = Hash.new(0)
        5000.times do
          subject.call(pool).each { |gene| totals[gene] += 1 }
        end

        expect(totals[gene_three]).to be > totals[gene_two]
        expect(totals[gene_two]).to be > totals[gene_one]

        expect((totals[gene_three] - 6600).abs).to be < 300, 'Proportions wrong'
        expect((totals[gene_two] - 3300).abs).to be < 300, 'Proportions wrong'
        expect((totals[gene_one] - 100).abs).to be < 300, 'Proportions wrong'
      end
    end
  end
end
