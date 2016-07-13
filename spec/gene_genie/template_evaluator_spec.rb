require 'minitest_helper'
require 'gene_genie/template_evaluator'

module GeneGenie
  describe TemplateEvaluator do
    subject { TemplateEvaluator.new(sample_template) }

    let(:tiny_check_template) { [{ a: 1..3 }] }
    let(:tiny_check_evaluator) { TemplateEvaluator.new(tiny_check_template) }

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
        a: 1..3,
        b: 1..10,
        c: 3..5
      },
      {
        d: 1..200,
        e: 1..500,
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
        assert_equal 57_170_244_609_000_000, huge_check_evaluator.permutations
      end
    end

    describe '#recommended_size' do
      it 'returns the number of permutations, if that value < 10' do
        assert_equal 3, tiny_check_evaluator.recommended_size
      end

      it 'normally returns permutations/100_000' do
        assert_equal  108, normal_check_evaluator.recommended_size
      end

      it 'return a minimum of 10 when permutations >10 and <100,000' do
        assert_equal 10, subject.recommended_size
      end

      it 'returns a maximum of 5000' do
        assert_equal 5000, huge_check_evaluator.recommended_size
      end
    end
  end
end
