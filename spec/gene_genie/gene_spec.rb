require 'minitest_helper'
require 'gene_genie/gene'

# The Gene class contains a specific set omodule GeneGenie
module GeneGenie
  describe Gene do
    let(:information) { { a: 10 } }
    let :fitness_evaluator do
      fitness_evaluator = MiniTest::Mock.new
      fitness_evaluator.expect :fitness, 1, [information]
    end
    let :higher_fitness_evaluator do
      fitness_evaluator = MiniTest::Mock.new
      fitness_evaluator.expect :fitness, 2, [information]
    end
    let :lower_fitness_evaluator do
      fitness_evaluator = MiniTest::Mock.new
      fitness_evaluator.expect :fitness, 0, [information]
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

    it "can compare it's fitness with other genes" do
       better_gene = Gene.new(information, higher_fitness_evaluator)
       assert_equal -1, subject <=> better_gene

       worse_gene = Gene.new(information, lower_fitness_evaluator)
       assert_equal 1, subject <=> worse_gene
    end
  end
end
