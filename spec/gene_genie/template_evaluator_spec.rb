require 'minitest_helper'
require 'gene_genie/template_evaluator'

module GeneGenie
  describe TemplateEvaluator do
    subject { TemplateEvaluator.new(sample_template) }

    let(:very_tiny_check_template) { [{ a: 1..1 }] }
    let(:very_tiny_check_evaluator) { TemplateEvaluator.new(very_tiny_check_template) }
    let(:tiny_check_template) { [{ a: 1..3 }] }
    let(:tiny_check_evaluator) { TemplateEvaluator.new(tiny_check_template) }

    let(:small_check_template) { [{ a: 1..10 }] }
    let(:small_check_evaluator) { TemplateEvaluator.new(small_check_template) }

    let(:normal_check_template) {
      [{
        a: 1..30,
        b: 1..10,
        c: 3..5,
        d: 10..20
      },
      {
        e: 35..45,
        f: 0..9,
        g: 1..10,
      }]
    }
    let(:normal_check_evaluator) { TemplateEvaluator.new(normal_check_template) }

    let(:huge_check_template) {
      [{
        a: 1..30000,
        b: 1..10000,
        c: 3..50000
      },
      {
        d: 1..200000,
        e: 1..500000,
        f: 300..80000,
        g: 300..80000,
      }]
    }
    let(:huge_check_evaluator) { TemplateEvaluator.new(huge_check_template) }

    describe 'initialize' do
      it 'takes a template' do
        assert_kind_of TemplateEvaluator, subject
      end
    end

    describe '#permutations' do
      it 'returns a value indicating how many possible permutations of the /
          template there are' do
        assert_equal 9900, subject.permutations
        assert_equal 3, tiny_check_evaluator.permutations
        assert_equal 10_890_000, normal_check_evaluator.permutations
        assert_equal 9_527_992_966_535_940_000_000_000_000_000_000,
          huge_check_evaluator.permutations
      end
    end

    describe '#recommended_size' do
      it 'returns a minimum of 3' do
        assert_equal 3, very_tiny_check_evaluator.recommended_size
      end

      it 'returns the number of permutations, if that value < 10' do
        assert_equal 3, tiny_check_evaluator.recommended_size
      end

      it 'normally returns log(permutations)^2' do
        assert_equal  263, normal_check_evaluator.recommended_size
      end

      it 'return a minimum of 6 when permutations are very low' do
        assert_equal 6, small_check_evaluator.recommended_size
      end

      it 'returns a maximum of 3000' do
        assert_equal 4000, huge_check_evaluator.recommended_size
      end
    end

    describe '.hash_valid?' do
      it 'returns true when the specified hash is valid for the template' do
        assert true, subject.hash_valid?([{a:50, b:50}])
      end

      it 'returns false when the specified hash is invalid for the template' do
        refute subject.hash_valid?([{a:3}])
        refute subject.hash_valid?([{b:3, c:50}])
      end
    end
  end
end
