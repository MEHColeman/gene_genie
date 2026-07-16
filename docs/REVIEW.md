# Gene Genie — Project Review & Roadmap

*Reviewed 2026-07-06, at version 0.1.1 (HEAD `bf720b2`). Suite run on Ruby 3.2.3: 74 examples; 2 stochastic specs fail intermittently (3 of 5 runs failed).*

> **Progress update (2026-07-07):** Phase 0 and the Phase 1 engine fixes are
> done (v0.3.0): seeded RNG throughout, ProportionalSelector plateau fix +
> bsearch, elitism, best-ever ordering fix, stagnation-based termination,
> OnePointCombiner as the single default, full API loaded from one require,
> GitHub Actions CI + RuboCop (clean), gemspec/Gemfile/Rakefile modernised,
> CHANGELOG added, Travis/`.ruby-version`/`test.sh` removed. Suite: 80
> examples, deterministic, verified green 13× in a row. The product-fitness
> benchmark that previously failed intermittently at 2000 generations now
> finds the exact optimum in ~20 generations, 5/5 unseeded runs.
>
> **Progress update (2026-07-16):** Phase 1 is complete and the bulk of
> Phase 2 shipped (v0.4.0): composable `Termination` criteria
> (max-generations / target-fitness / stagnation / max-time, `|`-combinable),
> `Genie#run` returning a `Result` (best, fitness, evaluations, elapsed,
> per-generation history), bare-Hash templates, block/callable fitness,
> `direction: :minimise`, float-range and choice-array gene types, Genie
> options pass-through (size/mutator/selector/combiner/elitism),
> `Mutator::`/`Selector::` namespacing with deprecated top-level aliases,
> `TournamentSelector`, `FitnessAdapter`, `Gene` equality/inspect. Suite:
> 121 deterministic examples; new examples (float minimisation, knapsack)
> verified against known optima — the GA finds the brute-forced knapsack
> optimum exactly.
> Remaining from Phase 2 for 1.0: permutation genomes, narrower selector
> interface, YARD docs site. Phases 3–5 (operator breadth, island model,
> parallel fitness, benchmark suite, 1.0 release) are future roadmap.

## 1. Current status — executive summary

Gene Genie is a small (~750 LOC lib), cleanly decomposed genetic algorithm gem with a
genuinely good architecture for its stated goals (fun, intuitive, open to extension).
The strategy-object design — pluggable `Selector`, `Combiner`, `Mutator`, `GeneFactory`,
`Listener`, all duck-typed on `#call` — is exactly the right shape for an extensible GA
library, and the two-tier API (`Genie` for one-liners, `GenePool` for control) is a good
idea well worth keeping.

However, the project is dormant (last substantive commits Aug 2023, docs-only), the
toolchain is dated (Travis CI, EOL Ruby 2.7 pin, no linter, no CHANGELOG), and — more
importantly — there are several real algorithmic bugs that make the default optimiser
much weaker than it should be. The README's own admission ("some of the tests don't
pass every time") is a symptom: the flaky specs are genuinely failing because the GA
sometimes fails to optimise a trivial problem, and the causes are identifiable and
fixable.

**Verdict: good bones, weak engine, dated packaging.** The path to "best possible GA
gem" is mostly about fixing the selection/elitism/termination core, adding
reproducibility (seeded RNG), and then broadening operators and gene types on top of the
already-sound plugin architecture.

## 2. What's genuinely good

- **Plugin architecture.** Every GA concern is a swappable object with a `#call`
  interface. Adding a new selector/combiner/mutator requires zero framework knowledge.
- **Two-tier API.** `Genie.new(template, evaluator).optimise` is close to the minimum
  possible ceremony. `GenePool` exposes the machinery for power users.
- **Fitness memoisation.** `Gene#fitness` caches (`gene.rb:25`) — the single most
  important performance property of a GA library, since user fitness functions dominate
  runtime.
- **Listener mechanism** for progress monitoring, with a ready-made `LoggingListener`.
- **`best_ever` tracking**, `optimise`/`optimize` alias, friendly `ArgumentError`s.
- **Examples directory** with four worked examples including a fun README gif.
- **Full test coverage by file** — every class has a spec; the RSpec migration is done.

## 3. Bugs (correctness)

Ordered roughly by impact.

### 3.1 `ProportionalSelector` collapses on fitness plateaus — `selector/proportional_selector.rb:29-33`
`rand(pool.total_normalised_fitness)` — when every gene has equal fitness (a plateau,
or a converged pool), all normalised fitnesses are 0, total is 0, and `rand(0)` returns
a **Float in [0,1)**, not 0. The accumulator loop's `total >= proportional_index` is
then never true (0 ≥ 0.31 is false), so the `index == pool.size - 1` fallback fires
every time: **the last gene in the pool is always selected, for both parents**.
Exactly when the population most needs diverse selection, selection degenerates to
cloning one individual. Also inherent to the design: the worst gene has normalised
fitness 0 and can effectively never be selected.

### 3.2 No elitism, and generation 0's best can be silently lost — `gene_pool.rb:77-90, 114-122`
`evolve` replaces the entire pool. The best individual is not carried over, so the
population routinely regresses (only the `best_ever` *record* survives, not the gene).
Worse, `@best_ever` is lazily memoised (`gene_pool.rb:74`): if a caller runs `evolve`
before ever touching `best`/`best_ever`, `update_stats` initialises `@best_ever` from
the *new* pool — generation 0's champion is dropped from the record too. (`Genie`
avoids this only by accident, because `optimise` reads `best_fitness` first.)

### 3.3 `Genie#optimise_by_strategy` termination is broken in both directions — `genie.rb:60-70`
The phase-2 loop breaks when a *single* generation improves best-ever fitness by less
than 0.1%. Because best-ever improvement is bursty (most generations improve it by
exactly 0), phase 2 almost always breaks after one generation — there is no patience
window. Conversely, when fitness is ≤ 0 (perfectly legitimate — the bundled
levenshtein example uses negative fitness), the `best_fitness > 0` guard means it
*never* breaks and always burns all 100 generations. So the "convergence strategy" is
effectively "run 51 generations" for positive fitness and "run 100" for negative.

### 3.4 `CoinFlipSelector` mutates the array it is iterating — `selector/coin_flip_selector.rb:15-27`
`selectees.delete(s)` inside `selectees.each` skips elements (classic
mutate-during-iteration). Additionally, after `second` is assigned there is no `break`,
so the loop keeps deleting genes and reassigning `second` until the pass ends. For a
pool of size 1 the `while` loop never terminates. It "works" only in the sense that it
returns two genes with some unintended distribution.

### 3.5 `Gene#normalised_fitness` memoises while ignoring its argument — `gene.rb:32-34`
`@normalised_fitness ||= fitness - minimum` returns a stale value if later called with
a different `minimum`. Latent in the default flow (genes are rebuilt each generation)
but a landmine for elitism, custom selectors, or any gene that survives across
generations — precisely the features on the roadmap.

### 3.6 Two different default combiners depending on construction path
`Gene`'s default is `OnePointCombiner` (`gene.rb:11`); `GeneFactory`'s default — the one
`Genie`/`GenePool.build` users actually get — is `WeightedAverageCombiner`
(`gene_factory.rb:14`). Weighted averaging contracts the population toward its centroid
(it can never generate a value outside the parents' range), which combined with 3.1 and
3.2 explains why the `optimise(2000)` spec sometimes fails a trivial maximisation.
Blend-style crossover is a fine *option* but a poor silent default, and its `.round`
(`weighted_average_combiner.rb:16`) silently forces integers, foreclosing float genes.

### 3.7 `require 'gene_genie'` does not load the advertised API — `lib/gene_genie.rb`
The entry point requires only `genie`. `UniformCombiner`, `SimpleGeneMutator`,
`CoinFlipSelector`, `LoggingListener` are unreachable without knowing internal file
paths. The README's Advanced Use section shows classes (`CustomMutator`, `GenePool`,
bare constant names) with no require guidance.

### 3.8 Smaller defects
- `TemplateEvaluator#recommended_size` doc says "1/1000th of permutations" but the code
  is `ln(permutations)²` capped at 20,000 (`template_evaluator.rb:17-28`).
- `TemplateEvaluator#permutations` and `NudgeMutator` rely on `Range#size`, which only
  has element-count semantics for integer ranges — float ranges (a stated goal, see the
  commented-out README section) break here, and newer Rubies are stricter about it.
- `GenePool#average_fitness` uses integer division (`gene_pool.rb:97`) — should be
  `fdiv`.
- `Genie#optimise` re-evaluates fitness on the best hashes (`genie.rb:37`) — a wasted
  (potentially expensive) evaluator call — and assigns `@best_fitness`, which nothing
  reads (`best_fitness` delegates to the pool). Dead store.
- `NudgeMutator`: `@mutation_rate = mutation_rate * 1` (`nudge_mutator.rb:10`) — the
  `* 1` does nothing; the 5% nudge width is hardcoded; and `GenePool.build` overrides
  NudgeMutator's own 0.04 default with 0.01, so the class default is dead code.
- Template validation duplicated in `GenePool.new` and `GenePool.build`, and only
  inspects `template[0]` — `[{a: 1..2}, "junk"]` passes.
- `hash_valid?` uses a bare `rescue` (`template_evaluator.rb:41`) that swallows
  everything including typos in the method itself.
- Typos: "GenePoo" (`genie.rb:12`), "specily" (`gene_pool.rb:32`), "nutator" and "a
  rather specified" (`nudge_mutator.rb:2-4`), "araray" (`gene_pool_spec.rb:152`),
  garbled comment (`gene_spec.rb:3`), and `test.sh`'s shebang is `!#/bin/bash`
  (backwards) invoking gems that aren't declared anywhere.

## 4. Design & interface review

### 4.1 The template format
`[{ a: 1..10, b: 3..100 }]` — an *array* of hashes. The outer array is pure ceremony
for nearly every use case (every example in the repo uses a single-element array), yet
it forces `[0]`s, `with_index` and two-level iteration through every combiner, mutator
and validator. Accept a bare `Hash` and normalise internally (keep accepting the array
form for compatibility). If the array level has a real purpose (repeated groups?),
document it; otherwise deprecate it.

### 4.2 The fitness interface
Requiring an object with a `#fitness` method is fine, but idiomatic Ruby would *also*
accept anything callable: `Genie.new(template) { |params| ... }` or a lambda. Trivial
to support (`respond_to?(:call)`), big ergonomic win.

### 4.3 Maximisation only
Minimisation requires the user to negate their fitness (as the levenshtein example
does) — and then bug 3.3 punishes them for having negative fitness. A
`direction: :minimise` option (internally negating) is table stakes for an
optimisation library.

### 4.4 No reproducibility
Global `rand` everywhere. No way to seed a run, reproduce a result, or write
deterministic tests — the direct cause of the flaky suite. Every stochastic component
should take a `random:` (a `Random` instance) and `Genie`/`GenePool.build` should
accept `seed:`.

### 4.5 `Genie` is a dead end for configurability
`Genie.new` takes exactly a template and an evaluator. Want a different pool size,
mutation rate, or selector? You must abandon `Genie` and hand-assemble a `GenePool`
(and then you *lose* `optimise`'s strategy loop, keeping only `evolve`). Options should
flow through: `Genie.new(template, evaluator, size:, mutator:, selector:, combiner:,
elitism:, seed:)`. The one item in the TODO file — a `.build` method with a default
convergence-criteria model — fits here.

### 4.6 No termination abstraction
Termination is either "n generations" or the broken strategy in 3.3. A small
`Termination` policy object (max generations / target fitness / stagnation with
patience window / wall-clock budget, composable with `|`) cleans up `Genie`, fixes 3.3
properly, and is a natural extension point.

### 4.7 Return values and results
`optimise` returns a boolean, `best` returns raw hashes, and stats (generation,
average fitness, history) are reachable only through a listener. A `Result` object —
best params, best fitness, generations run, evaluations count, per-generation history,
elapsed time — would serve the "monitor and understand my run" need directly.

### 4.8 Namespacing inconsistency
`GeneGenie::Combiner::OnePointCombiner` and `GeneGenie::Listener::LoggingListener` are
namespaced by role; `GeneGenie::NudgeMutator` and `GeneGenie::ProportionalSelector` sit
at top level despite living in `mutator/` and `selector/` directories. Pick one scheme
(namespaced, matching the directories) and alias the old names with deprecation
warnings.

### 4.9 Selector coupling
Selectors receive the whole pool and must know four of its methods
(`total_normalised_fitness`, `genes`, `worst_fitness`, `size` — the rdoc on
`ProportionalSelector` documents this contract). That's a wide interface for what is
conceptually "pick parents from a scored population". A narrower argument (genes +
fitness accessor, or a small `Population` view object) would decouple custom selectors
from `GenePool` internals.

### 4.10 Combiner stickiness
Combiners construct the child `Gene` and pass `gene_combiner: self`, so the combiner
choice propagates gene-to-gene rather than being a pool-level policy. It works, but
crossover is conceptually a population policy, and pool-level configuration
(`GenePool#combiner`) would let combiners return plain information instead of
constructing `Gene`s — simpler combiner implementations, one construction site.

## 5. Performance review

For a GA library the user's fitness function dominates, and fitness is memoised per
gene — the big thing is already right. Remaining, in order of real-world value:

1. **Parallel fitness evaluation** — nothing today. A `parallel:` option evaluating a
   generation's genes across processes (safest — user code is often not thread-safe),
   with a Ractor/thread backend as an experiment, is the single biggest practical win.
2. **Selection is O(n) per pick → O(n²) per generation** (`proportional_selector.rb`
   scans the pool for each of 2×n picks). Precompute cumulative normalised fitness once
   per generation and `bsearch` — O(n log n) — or use stochastic universal sampling
   (one spin, n picks, O(n)). Recommended sizes reach 20,000, where n² is felt.
3. **Allocation churn** — every child allocates fresh arrays/hashes per allele. Fine at
   current scale; a packed numeric genome representation could come later behind the
   same interface, driven by benchmarks rather than speculation.
4. Micro: `update_stats` recomputes best/worst/totals in separate passes (one pass
   suffices); `Genie#optimise`'s redundant re-evaluation (3.8).

Add a benchmark suite (benchmark-ips + classic GA test functions: OneMax, Sphere,
Rastrigin, small TSP) so "did we make it better?" has a number, and convergence-quality
regressions are caught the same way as speed regressions.

## 6. Tests & tooling

- **Flakiness is real and reproducible**: 3 of 5 full-suite runs failed on
  `genie_spec.rb:45` ("optimises") and `:76` ("returns optimised data"). These assert
  stochastic outcomes with no seed control. Fix = seeded RNG (4.4) + engine fixes
  (3.1/3.2/3.6); keep one *statistical* success-rate test tagged `:slow`/nightly.
- Specs poke internals (`instance_variable_get(:@listeners)` at
  `gene_pool_spec.rb:73-75`) and stub `gene_factory.create` to return `nil`, leaving a
  pool of `nil` that only accidentally never explodes. Empty pending specs
  (`genie_spec.rb:55-57`, `gene_pool_spec.rb:169-171`) should become real or be deleted.
- `spec_helper.rb` is the stock template with all the good suggestions (random order,
  `disable_monkey_patching!`, seed printing) still commented out.
- **CI is dead**: `.travis.yml` targets a defunct service and Ruby 2.7.1; `.ruby-version`
  pins EOL 2.7.6 (not even installed locally — the suite runs happily on 3.2.3).
  → GitHub Actions matrix over Ruby 3.1–3.4.
- **Gemspec**: no `metadata` (`source_code_uri`, `changelog_uri`,
  `rubygems_mfa_required`), deprecated `test_files`, `required_ruby_version >= 2.0.0`
  is fiction. No CHANGELOG at all.
- No linter (RuboCop/Standard). Style nits it would catch: `fail` vs `raise`, missing
  `frozen_string_literal`, hand-written readers instead of `attr_reader`
  (`gene_pool.rb:92-94`, `gene.rb:28-30`), `%q{}`.
- `Gene` has no `#==`/`#hash`/`#inspect` — debugging and duplicate-detection both want
  them.

## 7. Roadmap — the plan

The competitive landscape (darwinning, gga4r, ai4r) is largely abandoned;
[evolvable](https://github.com/mattruzicka/evolvable) is the active, DSL-heavy option.
Gene Genie's niche is credible: **the simplest possible entry point, honest pluggable
internals, reproducible runs, parallel evaluation, and documentation/benchmarks you can
trust.** Phases below are ordered so each ships something releasable.

### Phase 0 — Housekeeping (a day; ship as 0.2.0)
- Fix all §3.8 smaller defects and typos; deduplicate validation; `raise` over `fail`;
  `frozen_string_literal`; `attr_reader`s.
- `require 'gene_genie'` loads the full public API.
- GitHub Actions CI (Ruby 3.1–3.4 matrix), RuboCop or Standard, `.ruby-version` → 3.3+,
  gemspec metadata + MFA, CHANGELOG (Keep a Changelog), delete `.travis.yml`, fix or
  delete `test.sh`, update badges.
- README: fix stale claims, add require paths to Advanced Use.

### Phase 1 — Correct, deterministic engine (the substance; ship as 0.3.0)
- **Injectable RNG** everywhere (`random:` kwarg, `seed:` at the top level). Rewrite the
  flaky specs deterministically; move statistical assertions to a tagged nightly job.
  Delete the README apology.
- **Fix `ProportionalSelector`** (3.1): cumulative sums + `bsearch`, uniform fallback
  when total normalised fitness is 0.
- **Elitism** (3.2): `elitism: k` option carrying the top-k into the next generation;
  fix `best_ever` initialisation ordering.
- **Termination objects** (3.3/4.6): max-generations, target-fitness,
  stagnation-with-patience, max-time; `Genie#optimise` takes them; this also delivers
  the TODO file's `.build`-with-convergence-model item.
- **One default combiner** (3.6): `OnePointCombiner` (or uniform) as the true default;
  weighted-average stays as an explicit choice for numeric genes.
- Fix `normalised_fitness` memoisation (3.5); rewrite `CoinFlipSelector` as a proper
  rank/geometric selector or delete it (3.4).

### Phase 2 — The 1.0 interface
- Template: accept a bare Hash (normalise internally); keep array form working.
- Fitness: accept any `#call`-able or a block, as well as `#fitness` objects.
- `direction: :maximise | :minimise`.
- `Genie.new(template, evaluator, **options)` passes size/mutator/selector/combiner/
  elitism/seed through; consider a top-level convenience
  `GeneGenie.optimise(template, seed: 42) { |p| ... }`.
- **Gene types**: integer ranges (today), float ranges (gaussian/blend operators,
  fix `Range#size` uses), enumerated sets (`[:red, :green, :blue]`) — already promised
  by the commented-out README section. Permutation genomes (TSP-style) as a stretch.
- `Result` object from `optimise` (best, fitness, generations, evaluations, history,
  elapsed); richer listener events; consistent namespacing with deprecation aliases
  (4.8); narrower selector interface (4.9); pool-level combiner (4.10).
- YARD docs for every public class; docs site; examples for float optimisation,
  minimisation, TSP, knapsack.

### Phase 3 — Algorithmic breadth (1.1+)
- Selectors: **tournament** (the workhorse — should probably become the default), rank,
  stochastic universal sampling.
- Combiners: two-point, BLX-α / SBX for floats, OX/PMX for permutations.
- Mutators: gaussian (floats), adaptive/self-decaying rates, swap/shuffle
  (permutations).
- Diversity tooling: duplicate detection (needs `Gene#==`), population diversity
  metrics, optional fitness sharing/niching.
- Island model: multiple pools with periodic migration — parallelises naturally.

### Phase 4 — Performance
- `parallel:` fitness evaluation (process pool first; Ractors as experiment).
- O(n log n)/O(n) selection wired in (from Phase 1's cumulative sums), single-pass
  stats.
- Benchmark suite in-repo (benchmark-ips + convergence-quality tests on OneMax/
  Rastrigin/Sphere/TSP); publish honest comparisons vs evolvable/darwinning in README.

### Phase 5 — 1.0 release polish
- Semver commitment, CHANGELOG discipline, contribution guide refresh, potential logo,
  announce. The gem name is genuinely great — spend the goodwill on a solid 1.0.

## 8. TODO file reconciliation

The single item in `TODO` — *"add a .build method to GeneGenie, the same as GenePool,
to create a genie with a default convergence criteria model"* — is subsumed by Phase 1's
termination objects plus Phase 2's `Genie` options pass-through. Suggest replacing the
TODO file's contents with a pointer to this roadmap.
