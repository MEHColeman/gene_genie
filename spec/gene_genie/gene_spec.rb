require 'gene_genie/gene'

# The Gene class contains a specific set omodule GeneGenie
module GeneGenie
  RSpec.describe Gene do
    let(:information) { [{ a: 10, b: 20 }, { c: 30, d: 40 }] }
    let(:fitness_evaluator) { double :fitness_evaluator }
    let(:second_information) { [{ a: 11, b: 21 }, { c: 31, d: 41 }] }
    let(:second_gene) do
      Gene.new(information: second_information,
               fitness_evaluator: fitness_evaluator)
    end

    subject do
      Gene.new(information: information,
               fitness_evaluator: fitness_evaluator)
    end

    describe '#initialize' do
      it 'is initialised with an array of hashes and a fitness evaluator' do
        gene = Gene.new(information: information,
                        fitness_evaluator: fitness_evaluator)
        expect(gene).to be_kind_of Gene
      end

      it 'takes an optional gene_combiner' do
        gene = Gene.new(information: information,
                        fitness_evaluator: fitness_evaluator,
                        gene_combiner: Object.new)
        expect(gene).to be_kind_of Gene
      end

      it 'raises an ArgumentError if information is not an Array of Hashes' do
        expect { Gene.new({ a: 3 }, fitness_evaluator) }.to raise_error(ArgumentError)

        expect { Gene.new([:a, :b], fitness_evaluator) }.to raise_error(ArgumentError)
      end
    end

    describe '#to_hashes' do
      it 'returns the array of hashes' do
        expect(subject.to_hashes).to eq information
      end
    end

    describe '#fitness_evaluator' do
      it 'returns the fitness evaluator' do
        fitness_evaluator = Object.new
        subject = Gene.new(information: information,
                           fitness_evaluator: fitness_evaluator)
        expect(subject.fitness_evaluator).to eq fitness_evaluator
      end
    end

    describe '#fitness' do
      it 'uses the fitness_evaluator to get the fitness' do
        expect(fitness_evaluator).to receive(:fitness).with(information).and_return(1)
        expect(subject.fitness).to eq 1
      end
    end

    describe '#normalised_fitness' do
      it 'returns a normalised fitness, based on the minimum pool fitness' do
        expect(fitness_evaluator).to receive(:fitness).with(information).and_return(1)
        expect(subject.normalised_fitness(1)).to eq 0
      end
    end

    it "can compare it's fitness with other genes" do
      expect(fitness_evaluator).to receive(:fitness).with(information).and_return(1)

      higher_fitness_evaluator = double :higher_fitness_evaluator
      better_gene = Gene.new(information: information,
                             fitness_evaluator: higher_fitness_evaluator)

      expect(higher_fitness_evaluator).to receive(:fitness).with(information).and_return(2)
      expect(subject <=> better_gene).to eq -1

      lower_fitness_evaluator = double :lower_fitness_evaluator
      worse_gene = Gene.new(information: information,
                            fitness_evaluator: lower_fitness_evaluator)

      expect(lower_fitness_evaluator).to receive(:fitness).with(information).and_return(0)
      expect(subject <=> worse_gene).to eq 1
    end

    describe '#mutate' do
      it 'uses the provided mutator to change the its internal information' do
        altered_hash = { b: 2 }
        mutator = double :mutator
        expect(mutator).to receive(:call).with(information).once.and_return(altered_hash)

        subject.mutate(mutator)

        expect(subject.to_hashes).to eq altered_hash
      end
    end

    describe '#combine' do
      it 'calls the configured gene combiner' do
        gene_combiner = double :gene_combiner
        test_subject = Gene.new(information: information,
                                fitness_evaluator: fitness_evaluator,
                                gene_combiner: gene_combiner)

        expect(gene_combiner).to receive(:call).with(test_subject, second_gene).
          once.and_return(Object.new)
        test_subject.combine(second_gene)
      end

      it 'returns a Gene' do
        expect(subject.combine(second_gene)).to be_kind_of Gene
      end
    end
  end
end
