# TODO

## Inbox

- [ ] Decide whether to pin RuboCop instead of letting CI float to the newest release
    - **Why:** On 2026-08-04 the CI lint job went red with 15 offences on code nobody had touched. `Gemfile.lock` is gitignored (`.gitignore:2`), so CI's `bundler-cache: true` re-resolves `rubocop` to the newest release on every run, and `.rubocop.yml` sets `NewCops: enable` — so a brand-new cop is live in CI the day it ships. `Naming/PredicateMethod` (RuboCop 1.78) accounted for 3 of the 15. This will recur.
    - **Files:** `Gemfile` (the `gem 'rubocop', require: false` line in the `:development` group), `.rubocop.yml` (`AllCops.NewCops`), `.gitignore:2`, `.github/workflows/ci.yml` (the `lint` job).
    - **Known:** Mark chose on 2026-08-04 to fix the offences only and leave the drift — this item is the record, not a reversal. CI currently resolves 1.88.2. Committing `Gemfile.lock` is the other lever but is unconventional for a published gem, since the lock does not constrain consumers and can mask a genuine dependency break.
    - **Approach:** Either pin (`gem 'rubocop', '~> 1.88', require: false`) so new cops arrive on a deliberate bump, or set `NewCops: disable` and opt cops in by hand. Pinning is the stronger of the two — existing cops also change behaviour between minor versions, which `NewCops: disable` does not protect against.
    - **Done when:** A rubocop release containing a new cop cannot turn the `lint` job red without someone changing a tracked file; the choice and its reasoning are in `docs/journal.md`.

- [ ] Install ruby-dev and confirm the full `bundle install` workflow works locally
    - **Why:** Local `bundle install` was fixed on 2026-08-03 (PATH + user BUNDLE_PATH) but still stops at the prism C extension — no ruby headers on this machine, and installing them needs a password Claude doesn't have.
    - **Files:** `~/.dotfiles/zshrc` (PATH line for `~/.local/share/gem/ruby/3.2.0/bin`), `~/.bundle/config` (`BUNDLE_PATH: /home/mark/.local/share/gem/bundle`).
    - **Known:** gcc/make already present; rake, rspec and all pure-Ruby gems installed; suite green (122 examples) via `GEM_HOME=~/.local/share/gem/bundle/ruby/3.2.0 ~/.local/share/gem/bundle/ruby/3.2.0/bin/rspec`. Failure without headers: `An error occurred while installing prism (1.9.0)` (rubocop 1.88.2 → rubocop-ast 1.50.0 → prism).
    - **Known (2026-08-04):** The headers are now present — `/usr/include/ruby-3.2.0/ruby.h` exists, `ruby -e 'require "mkmf"'` loads, and `prism 1.9.0` compiled its native extension cleanly during a scratchpad-`BUNDLE_PATH` install, after which `bundle exec rubocop` (1.88.2) and `bundle exec rspec` both ran. So the `sudo apt install ruby-dev` step looks already done. What is still unverified is Mark's own plain workflow: this agent shell's PATH does **not** include `~/.local/share/gem/ruby/3.2.0/bin`, so `bundle` is still not directly on PATH here and the dotfiles PATH line may only apply to interactive shells. Nothing was installed into `~/.local/share/gem/bundle` this session.
    - **Approach:** In a fresh interactive shell, run `bundle install` in the repo (no `GEM_HOME`/`BUNDLE_PATH` overrides), then `bundle exec rspec` and `bundle exec rubocop`. If `bundle: command not found` still appears, check whether the zshrc PATH line sits in an interactive-only block.
    - **Done when:** All three commands succeed in a fresh shell with no GEM_HOME tricks; agent memory note `gene-genie-dev-env` updated to drop the "remaining gap" paragraph.

## Doing

## Done
