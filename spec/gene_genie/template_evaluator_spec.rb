require 'gene_genie/template_evaluator'

require 'support/samples'

module GeneGenie
  RSpec.describe TemplateEvaluator do
    subject { TemplateEvaluator.new(sample_template) }

    let(:very_tiny_check_template) { [{ a: 1..1 }] }
    let(:very_tiny_check_evaluator) { TemplateEvaluator.new(very_tiny_check_template) }
    let(:tiny_check_template) { [{ a: 1..3 }] }
    let(:tiny_check_evaluator) { TemplateEvaluator.new(tiny_check_template) }

    let(:small_check_template) { [{ a: 1..10 }] }
    let(:small_check_evaluator) { TemplateEvaluator.new(small_check_template) }

    let(:normal_check_template) do
      [{
        a: 1..30,
        b: 1..10,
        c: 3..5,
        d: 10..20
      },
      {
        e: 35..45,
        f: 0..9,
        g: 1..10
      }]
    end
    let(:normal_check_evaluator) { TemplateEvaluator.new(normal_check_template) }

    let(:huge_check_template) do
      [{
        a: 1..30000,
        b: 1..10000,
        c: 3..50000
      },
      {
        d: 1..200000,
        e: 1..500000,
        f: 300..80000,
        g: 300..80000
      }]
    end
    let(:huge_check_evaluator) { TemplateEvaluator.new(huge_check_template) }

    describe 'initialize' do
      it 'takes a template' do
        expect(subject).to be_kind_of TemplateEvaluator
      end
    end

    describe '#permutations' do
      it 'returns a value indicating how many possible permutations of the /
          template there are' do
            expect(subject.permutations).to eq 9900
            expect(tiny_check_evaluator.permutations).to eq 3
            expect(normal_check_evaluator.permutations).to eq 10_890_000
            expect(huge_check_evaluator.permutations).to eq 9_527_992_966_535_940_000_000_000_000_000_000
          end
    end

    describe '#recommended_size' do
      it 'returns a minimum of 3' do
        expect(very_tiny_check_evaluator.recommended_size).to eq 3
      end

      it 'returns the number of permutations, if that value < 10' do
        expect(tiny_check_evaluator.recommended_size).to eq 3
      end

      it 'normally returns log(permutations)^2' do
        expect(normal_check_evaluator.recommended_size).to eq 263
      end

      it 'return a minimum of 6 when permutations are very low' do
        expect(small_check_evaluator.recommended_size).to eq 6
      end

      it 'returns a maximum of 3000' do
        expect(huge_check_evaluator.recommended_size).to eq 5000
      end
    end

    describe '.hash_valid?' do
      it 'returns true when the specified hash is valid for the template' do
        expect(subject.hash_valid?([{ a: 50, b: 50 }])).to be_truthy
      end

      it 'returns false when the specified hash is invalid for the template' do
        expect(subject.hash_valid?([{ a: 3 }])).to be_falsey
        expect(subject.hash_valid?([{ b: 3, c: 50 }])).to be_falsey
      end
    end
  end
end
