## Session 96984162 — 2026-07-07T00:00:00

### 2026-07-06 — request

User asked for a thorough soft review of the gene_genie gem — architecture, design, interface, performance, idiomatic Ruby — plus a status report and a phased plan to make it "the best possible genetic algorithm gem", folding in the TODO file. Review delivered to docs/REVIEW.md. Next day the user said "let's go" to start executing the plan (Phase 0 housekeeping + Phase 1 engine fixes).

---

### 2026-07-07 — actions

Executed Phase 0 + core Phase 1 of the roadmap; version bumped to 0.3.0. Engine fixes: ProportionalSelector plateau collapse fixed (uniform fallback + cumulative-sum bsearch, cached per generation), elitism added to GenePool (`elitism:` kwarg, default 1), best_ever initialisation-ordering bug fixed, Genie's broken convergence heuristic replaced with stagnation patience (15 gens, max 100), injectable RNG everywhere (`random:` kwargs; `Genie.new(..., seed: 42)`), single default combiner (OnePointCombiner), Gene#normalised_fitness memoisation-ignoring-argument fixed, CoinFlipSelector rewritten (was mutating the array it iterated). Housekeeping: full API loaded from `require 'gene_genie'`, GitHub Actions CI (Ruby 3.1–3.4 + RuboCop), .rubocop.yml (clean), gemspec modernised (metadata, MFA, ruby >= 3.1), dev deps moved to Gemfile, Rakefile simplified, CHANGELOG.md added, README rewritten (seed docs, corrected Advanced Use), Travis/.ruby-version/test.sh deleted, typos fixed. Specs: stochastic tests seeded (deterministic now), new tests for elitism, best_ever regression, plateau fallback, seed reproducibility, stagnation stop; spec_helper enables monkey-patch-free mode + random order.

**Details:**
- 41 files changed, 653 insertions, 464 deletions (uncommitted)
- Env note: pinned Ruby 2.7.6 absent; used RBENV_VERSION=system (3.2.3) with GEM_HOME in session scratchpad; rubocop 1.60.2 pinned (prism native ext fails to build without ruby-dev headers)

---

### 2026-07-07 — evaluation

Suite deterministic-green (80 examples) across 13 consecutive runs with randomised order; RuboCop clean; end-to-end examples verified. Optimisation quality dramatically improved: the product-fitness problem the old engine intermittently failed at 2000 generations now finds the exact optimum in ~20 generations, 5/5 unseeded runs.

**Details:**
```
$ rubocop
38 files inspected, no offenses detected

$ rspec (x5)
80 examples, 0 failures  (repeated 5x; 8 earlier runs also green)

$ ruby -I lib examples/sum.rb | tail -1
[{:a=>100, :b=>1000, :c=>1, :d=>50}]          # exact global optimum (1151)

$ product problem, 5 unseeded runs:
run 0: fitness=10000 generations=20 (max 10000)
run 1: fitness=10000 generations=29
run 2: fitness=10000 generations=19
run 3: fitness=10000 generations=17
run 4: fitness=10000 generations=23

$ ruby -I lib examples/simpler_string/simpler_string.rb | tail -2
testing 4200                                   # evolved exactly "testing"
```

---

### 2026-07-16 — actions

Completed the remaining Phase 1 item and the bulk of Phase 2 (v0.4.0), per the user's /goal to complete all outstanding actions. Added: composable Termination criteria (MaxGenerations/TargetFitness/Stagnation/MaxTime, `|`-combinable, or any call(pool)-able), Genie#run returning a Result (best, fitness, generations, evaluation count, elapsed, per-generation history), bare-Hash templates (best returned in matching shape), block/lambda fitness functions, direction: :minimise (with :minimize alias; targets and reported fitness translated), float ranges and choice arrays as gene types (factory sampling, nudge/simple mutators, validator, pool sizing), Genie pass-through of size/mutator/selector/combiner/elitism, Mutator::/Selector:: namespaces with deprecated top-level aliases, Selector::TournamentSelector, FitnessAdapter (wraps evaluators for GenePool use, counts evaluations), Gene equality/hash/inspect, GenePool#unregister_listener. New examples: float_optimisation.rb, knapsack.rb. README rewritten for the new interface; CHANGELOG 0.4.0.

---

### 2026-07-16 — evaluation

121 examples green (repeated runs, randomised order), RuboCop clean (46 files). End-to-end: float minimisation converges to (2.359, -1.206) vs optimum (2.37, -1.2) in 57 generations/42ms; knapsack example finds value 48, confirmed as the exact optimum by brute force over all 1024 packings; pre-existing sum and string examples still find their exact optima.

**Details:**
```
$ rspec (x3 + earlier x5)
121 examples, 0 failures

$ rubocop
46 files inspected, no offenses detected

$ ruby -I ../lib float_optimisation.rb
best:        {:x=>2.3590111767993918, :y=>-1.2061050608957986}
fitness:     0.00015802600387563806
generations: 57 / evaluations: 11021 / elapsed: 0.042s

$ ruby -I ../lib knapsack.rb
pack:   stove, water, first_aid, torch, food, map
value:  48   # brute-force optimum: 48
weight: 26/30
```

---

### 2026-07-16 — actions — docs-sync

Docs freshness hook flagged the doc surfaces; ran a full docs-sync walk, executing every runnable README snippet against the code. Caught two broken snippets and one real API bug: (1) the quick-start passed a bare hash without braces, which Ruby 3 keyword separation turns into unknown keywords - fixed with braces plus an explanatory note; (2) the Summer example implicitly reused the mixed-type template (symbols can't be summed) - given its own numeric template; (3) real bug: components built by users from a bare Hash template (e.g. `SimpleGeneMutator.new(template, 0.02)`) crashed inside Genie because they index the template as an array - all template-taking components (GeneFactory, TemplateEvaluator, SimpleGeneMutator, NudgeMutator) now normalise bare hashes, with a regression spec. Also fixed example README code fences and typos, and verified every snippet plus all five examples run: 122 examples green, RuboCop clean.

---

### 2026-08-03 — environment — local bundle install fixed (one sudo step outstanding)

Mark hit `bundle: command not found` locally despite the repo being "updated and tested" — testing had been via GitHub CI (Ruby 3.1–3.4) and, in earlier agent sessions, a scratchpad-GEM_HOME rspec workaround, so local bundler was never exercised. Root causes on this machine: bundler 2.7.2 was user-installed at `~/.local/share/gem/ruby/3.2.0/bin` but that dir wasn't on PATH; bundler then tried to install into root-owned `/var/lib/gems`; and there are no ruby-dev headers, so the prism C extension (pulled by modern rubocop via rubocop-ast) can't compile. Fixed the first two (PATH line in dotfiles zshrc; global `BUNDLE_PATH` → `~/.local/share/gem/bundle`): `bundle` now resolves in a fresh shell and all pure-Ruby dev gems install. Verified the suite green from the new gem path: 122 examples, 0 failures. Remaining: `sudo apt install ruby-dev`, then `bundle install` should complete and `bundle exec rspec` / `bundle exec rubocop` become the plain workflow (tracked in docs/TODO.md).

---

### 2026-08-04 — decision — `evolve` and `optimise` keep returning a boolean

CI lint went red on 15 RuboCop offences, three of which were `Naming/PredicateMethod` objecting that `GenePool#evolve` and `Genie#optimise` return booleans without a `?` suffix. Considered renaming them and considered returning `self` or a `Result` for chaining. Both rejected, and the reasoning is worth keeping: the boolean is not a success flag — a failed run raises — it reports **whether the best fitness improved** (`best.fitness > old_best_fitness`; `run(...).improved?`). That is an outcome report attached to a command verb, so `improved?`/`evolved?` would misdescribe a method that runs 100 generations as a cheap query. Returning `self` or a `Result` is worse than a rename: both are always truthy, so every existing `if genie.optimise` caller would silently invert with nothing raised. The boolean is therefore deliberate and stays; the cop is told so via `AllowedMethods` in `.rubocop.yml`. If the boolean ever does go, it is a 0.5.0 breaking change with `Result#improved?` as the migration path, not a lint tidy-up.

---

### 2026-08-04 — actions — clear the RuboCop 1.88 offences

Fixed all 15: `validate_template!` now uses the pattern form `template.all?(Hash)` (`Style/PredicateWithKind`); `.rubocop.yml` gained the `Naming/PredicateMethod` allow-list above; and 12 assertions across the three combiner specs moved off raw boolean expressions onto matchers — `eq(10).or eq(30)` for membership, `be_between(10, 30)` for ranges — which also fixes their failure output, previously `expected true, got false` with the actual value hidden.

Two findings worth recording. First, `be_in([10, 30])` looks like the obvious matcher and **is not one**: RSpec resolves it as a dynamic predicate matcher calling `Object#in?`, which only exists under ActiveSupport, so it fails with "expected 30 to respond to `in?`". Second, the allow-list must re-list `call` even though it is already the cop's default — a project-level `AllowedMethods` replaces the default rather than merging. Verified by running the cop with `call` removed: four fresh offences in `lib/gene_genie/termination.rb`, where the criteria's `#call(pool)` returns a boolean by design.

Cause worth flagging: none of this code changed. `Gemfile.lock` is gitignored, so CI's `bundler-cache: true` re-resolves rubocop to the newest release every run, and `.rubocop.yml` sets `NewCops: enable` — `Naming/PredicateMethod` only shipped in RuboCop 1.78. Lint will go red again the next time a relevant cop lands. Left alone by decision this session; captured in docs/TODO.md.

---

### 2026-08-04 — evaluation

122 examples green, RuboCop clean at 1.88.2 — the same version CI resolves, so the cop set that failed is the cop set that now passes.

**Details:**
```
$ bundle exec rubocop --version
1.88.2

$ bundle exec rubocop
46 files inspected, no offenses detected

$ bundle exec rspec
122 examples, 0 failures

$ bundle exec rubocop -c <allow-list minus `call`> --only Naming/PredicateMethod lib
20 files inspected, 4 offenses detected   # all in termination.rb - confirms the re-listing
```

Also resolved incidentally: the ruby-dev headers this machine lacked on 2026-08-03 are now present (`/usr/include/ruby-3.2.0/ruby.h`, `mkmf` loads), and prism 1.9.0 compiled its native extension cleanly during install.

---
