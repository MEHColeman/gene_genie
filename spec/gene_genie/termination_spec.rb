require 'gene_genie/termination'

module GeneGenie
  RSpec.describe Termination do
    let(:pool) { double :pool }

    describe Termination::MaxGenerations do
      it 'stops after the given number of generations from the start of the run' do
        criterion = Termination::MaxGenerations.new(5)

        allow(pool).to receive(:generation).and_return(10)
        expect(criterion.call(pool)).to be false

        allow(pool).to receive(:generation).and_return(14)
        expect(criterion.call(pool)).to be false

        allow(pool).to receive(:generation).and_return(15)
        expect(criterion.call(pool)).to be true
      end

      it 'counts from the current generation again after a reset' do
        criterion = Termination::MaxGenerations.new(5)
        allow(pool).to receive(:generation).and_return(15)
        criterion.call(pool)

        criterion.reset

        expect(criterion.call(pool)).to be false
      end
    end

    describe Termination::TargetFitness do
      it 'stops once the best-ever fitness reaches the target' do
        criterion = Termination::TargetFitness.new(100)

        allow(pool).to receive(:best_ever).and_return(double(fitness: 99))
        expect(criterion.call(pool)).to be false

        allow(pool).to receive(:best_ever).and_return(double(fitness: 100))
        expect(criterion.call(pool)).to be true
      end
    end

    describe Termination::Stagnation do
      it 'stops once fitness has not improved for `patience` generations' do
        criterion = Termination::Stagnation.new(2)
        allow(pool).to receive(:best_ever).and_return(double(fitness: 1))

        expect(criterion.call(pool)).to be false # establishes the baseline
        expect(criterion.call(pool)).to be false # 1 stagnant generation
        expect(criterion.call(pool)).to be true  # 2 stagnant generations
      end

      it 'resets its patience when fitness improves' do
        criterion = Termination::Stagnation.new(2)

        allow(pool).to receive(:best_ever).and_return(double(fitness: 1))
        criterion.call(pool)
        criterion.call(pool)

        allow(pool).to receive(:best_ever).and_return(double(fitness: 2))
        expect(criterion.call(pool)).to be false

        allow(pool).to receive(:best_ever).and_return(double(fitness: 2))
        expect(criterion.call(pool)).to be false
        expect(criterion.call(pool)).to be true
      end
    end

    describe Termination::MaxTime do
      it 'stops once the elapsed time exceeds the limit' do
        time = 0
        criterion = Termination::MaxTime.new(10, clock: -> { time })

        expect(criterion.call(pool)).to be false

        time = 9
        expect(criterion.call(pool)).to be false

        time = 10
        expect(criterion.call(pool)).to be true
      end
    end

    describe 'composition' do
      it 'combines criteria with |, stopping when any is met' do
        met = Termination::TargetFitness.new(10)
        unmet = Termination::MaxGenerations.new(1000)
        allow(pool).to receive(:best_ever).and_return(double(fitness: 10))
        allow(pool).to receive(:generation).and_return(0)

        also_unmet = Termination::MaxGenerations.new(500)

        expect((unmet | met).call(pool)).to be true
        expect((unmet | also_unmet).call(pool)).to be false
      end

      it 'resets all composed criteria' do
        first = Termination::MaxGenerations.new(5)
        second = Termination::Stagnation.new(1)
        composed = first | second

        allow(pool).to receive(:generation).and_return(10)
        allow(pool).to receive(:best_ever).and_return(double(fitness: 1))
        composed.call(pool)

        expect { composed.reset }.not_to raise_error
        expect(composed.call(pool)).to be false
      end
    end
  end
end
