# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-07-07

### Fixed

- `ProportionalSelector` no longer degenerates when every gene in the pool has
  the same fitness. Previously a converged (or plateaued) pool would always
  select the last gene as both parents; it now falls back to uniform random
  selection. Selection also uses a cumulative-sum binary search instead of a
  linear scan.
- `GenePool#best_ever` now remembers the best gene of the initial population
  even when `evolve` is called before any stats are read.
- `Genie#optimise` (with no generation count) previously stopped after the
  first generation that didn't improve fitness by 0.1%, and never stopped
  early at all for zero/negative fitness values. It now evolves until the
  best fitness has not improved for 15 consecutive generations
  (`Genie::STAGNATION_PATIENCE`), up to a maximum of 100
  (`Genie::DEFAULT_MAX_GENERATIONS`).
- `CoinFlipSelector` no longer mutates the list it is iterating (which
  skipped genes and could loop forever on tiny pools). It now always returns
  two distinct genes when the pool holds more than one.
- `Gene#normalised_fitness` no longer memoises its result while ignoring the
  baseline argument - it previously returned stale values when called with a
  different baseline.
- `GenePool#average_fitness` no longer truncates to an integer.
- `require 'gene_genie'` now loads the entire public API, including all
  combiners, mutators, selectors and the logging listener.

### Added

- Reproducible runs: `Genie.new(template, evaluator, seed: 42)`. All
  stochastic components (`GeneFactory`, combiners, mutators, selectors) now
  accept a `random:` keyword taking a `Random` instance, and
  `GenePool.build` accepts `random:` and threads it through.
- Elitism: `GenePool.new` accepts `elitism:` (default 1) - the top genes are
  carried into the next generation unchanged, so the population's best
  fitness never regresses.
- `Genie#gene_pool` and `GenePool#generation` readers.
- `NudgeMutator` accepts a `nudge_fraction:` keyword (default 0.05)
  controlling the maximum nudge size as a fraction of the allele's range.
- CHANGELOG, GitHub Actions CI (Ruby 3.1-3.4 matrix + RuboCop), RuboCop
  configuration.

### Changed

- The default combiner used by `GeneFactory` (and therefore by `Genie` and
  `GenePool.build`) is now `OnePointCombiner`, matching `Gene`'s own default.
  It was previously `WeightedAverageCombiner`, which cannot produce values
  outside its parents' range and so tended to collapse the population toward
  its centroid.
- `GenePool.build` now uses `NudgeMutator`'s default mutation rate (0.04)
  instead of overriding it to 0.01.
- Minimum supported Ruby version is now 3.1 (was 2.0). Removed the Travis CI
  configuration and the `.ruby-version` pin to EOL Ruby 2.7.6.
- Development dependencies moved from the gemspec to the Gemfile; gemspec
  modernised (metadata, MFA requirement).

## [0.1.1] and earlier

See the git history.
