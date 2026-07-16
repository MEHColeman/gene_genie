# frozen_string_literal: true

require_relative 'gene_genie/version'
require_relative 'gene_genie/genie'
require_relative 'gene_genie/gene_pool'
require_relative 'gene_genie/gene'
require_relative 'gene_genie/gene_factory'
require_relative 'gene_genie/template_evaluator'
require_relative 'gene_genie/fitness_adapter'
require_relative 'gene_genie/termination'
require_relative 'gene_genie/result'
require_relative 'gene_genie/combiner/one_point_combiner'
require_relative 'gene_genie/combiner/uniform_combiner'
require_relative 'gene_genie/combiner/weighted_average_combiner'
require_relative 'gene_genie/mutator/null_mutator'
require_relative 'gene_genie/mutator/simple_gene_mutator'
require_relative 'gene_genie/mutator/nudge_mutator'
require_relative 'gene_genie/selector/proportional_selector'
require_relative 'gene_genie/selector/coin_flip_selector'
require_relative 'gene_genie/selector/tournament_selector'
require_relative 'gene_genie/listener/logging_listener'

module GeneGenie
  # Mutators and selectors moved into the Mutator:: and Selector::
  # namespaces in 0.4.0, matching their directories and the Combiner::
  # namespace. These aliases keep old code working; they will be removed
  # in 1.0.
  NullMutator = Mutator::NullMutator
  SimpleGeneMutator = Mutator::SimpleGeneMutator
  NudgeMutator = Mutator::NudgeMutator
  ProportionalSelector = Selector::ProportionalSelector
  CoinFlipSelector = Selector::CoinFlipSelector

  deprecate_constant :NullMutator, :SimpleGeneMutator, :NudgeMutator,
                     :ProportionalSelector, :CoinFlipSelector
end
