require 'minitest_helper'
require 'gene_genie/gene'

# The Gene class contains a specific set omodule GeneGenie
module GeneGenie
  describe Gene do
    let :information do { a: 10 } end
    let :fitness_evaluator do
      fitness_evaluator = MiniTest::Mock.new
      fitness_evaluator.expect :fitness, 1, [information]
    end

    subject { Gene.new(information, fitness_evaluator) }

    describe '#initialize' do
      it 'is initialised with a hash and a fitness evaluator' do
        gene = Gene.new(information, fitness_evaluator)
        assert_kind_of Gene, gene
      end
    end

    describe '#to_hash' do
      it 'returns the hash' do
        assert_equal information, subject.to_hash
      end
    end

    describe '#fitness' do
      it 'uses the fitness_evaluator to get the fitness' do
        assert_equal 1, subject.fitness
        fitness_evaluator.verify
      end
    end
  end
end
