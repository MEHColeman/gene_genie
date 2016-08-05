require 'minitest_helper'
require 'gene_genie/gene'

# The Gene class contains a specific set omodule GeneGenie
module GeneGenie
  describe Gene do
    let(:information) {
      [
        { a: 10, b: 20, },
        { c: 30, d: 40, },
      ]
    }
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
    let(:second_information) { [{ a: 11, b: 21 }, { c: 31, d: 41 }] }
    let(:second_gene) { Gene.new(second_information, fitness_evaluator) }

    subject { Gene.new(information, fitness_evaluator) }

    describe '#initialize' do
      it 'is initialised with an array of hashes and a fitness evaluator' do
        gene = Gene.new(information, fitness_evaluator)
        assert_kind_of Gene, gene
      end

      it 'raises an ArgumentError if information is not an Array of Hashes' do
        assert_raises(ArgumentError) do
          Gene.new({a:3}, fitness_evaluator)
        end
        assert_raises(ArgumentError) do
          Gene.new([:a,:b], fitness_evaluator)
        end
      end
    end

    describe '#to_hashes' do
      it 'returns the array of hashes' do
        assert_equal information, subject.to_hashes
      end
    end

    describe '#fitness' do
      it 'uses the fitness_evaluator to get the fitness' do
        assert_equal 1, subject.fitness
        fitness_evaluator.verify
      end
    end

    describe '#normalised_fitness' do
      it 'returns a normalised fitness, based on the minimum pool fitness' do
        assert_equal 0, subject.normalised_fitness(1)
      end
    end

    it "can compare it's fitness with other genes" do
      better_gene = Gene.new(information, higher_fitness_evaluator)
      assert_equal -1, subject <=> better_gene

      worse_gene = Gene.new(information, lower_fitness_evaluator)
      assert_equal 1, subject <=> worse_gene
    end

    describe '#mutate' do
      it 'uses the provided mutator to change the its internal information' do
        altered_hash = { b: 2 }
        mutator = MiniTest::Mock.new
        mutator.expect :call, altered_hash, [information]

        subject.mutate(mutator)

        mutator.verify
        assert_equal altered_hash, subject.to_hashes
      end
    end

    describe '#combine' do
      it 'combines information from the specified gene to create a new gene' do
        new_gene_hash = subject.combine(second_gene).to_hashes

        assert new_gene_hash[0][:a] == 10 || new_gene_hash[0][:a] == 11
        assert new_gene_hash[0][:b] == 20 || new_gene_hash[0][:b] == 21
        assert new_gene_hash[1][:c] == 30 || new_gene_hash[1][:c] == 31
        assert new_gene_hash[1][:d] == 40 || new_gene_hash[1][:d] == 41
      end

      it 'returns a Gene' do
        assert_kind_of Gene, subject.combine(second_gene)
      end
    end
  end
end
