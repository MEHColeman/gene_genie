require 'gene_genie/fitness_adapter'

module GeneGenie
  RSpec.describe FitnessAdapter do
    let(:information) { [{ a: 2, b: 3 }] }

    describe '#fitness' do
      it 'delegates to an evaluator that responds to #fitness' do
        evaluator = double :evaluator
        expect(evaluator).to receive(:fitness).with(information).and_return(6)

        adapter = FitnessAdapter.new(evaluator)

        expect(adapter.fitness(information)).to eq 6
      end

      it 'accepts any callable as the evaluator' do
        adapter = FitnessAdapter.new(->(params) { params.first[:a] + params.first[:b] })

        expect(adapter.fitness(information)).to eq 5
      end

      it 'negates scores when minimising' do
        adapter = FitnessAdapter.new(->(_params) { 5 }, direction: :minimise)

        expect(adapter.fitness(information)).to eq(-5)
      end

      it 'unwraps the array for bare Hash templates' do
        adapter = FitnessAdapter.new(->(params) { params[:a] }, bare_template: true)

        expect(adapter.fitness(information)).to eq 2
      end

      it 'counts evaluations' do
        adapter = FitnessAdapter.new(->(_params) { 1 })
        3.times { adapter.fitness(information) }

        expect(adapter.evaluations).to eq 3
      end
    end

    describe '#to_user' do
      it 'translates internal fitness back to the user space when minimising' do
        adapter = FitnessAdapter.new(->(_params) { 5 }, direction: :minimise)

        expect(adapter.to_user(adapter.fitness(information))).to eq 5
      end
    end

    describe '#initialize' do
      it 'accepts American spellings of direction' do
        expect(FitnessAdapter.new(->(_p) { 1 }, direction: :minimize).direction).to eq :minimise
        expect(FitnessAdapter.new(->(_p) { 1 }, direction: :maximize).direction).to eq :maximise
      end

      it 'rejects unknown directions' do
        expect do
          FitnessAdapter.new(->(_p) { 1 }, direction: :sideways)
        end.to raise_error ArgumentError
      end

      it 'rejects evaluators that respond to neither #fitness nor #call' do
        expect { FitnessAdapter.new(Object.new) }.to raise_error ArgumentError
      end
    end
  end
end
