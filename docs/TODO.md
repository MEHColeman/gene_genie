# TODO

## Inbox

- [ ] Install ruby-dev and confirm the full `bundle install` workflow works locally
    - **Why:** Local `bundle install` was fixed on 2026-08-03 (PATH + user BUNDLE_PATH) but still stops at the prism C extension — no ruby headers on this machine, and installing them needs a password Claude doesn't have.
    - **Files:** `~/.dotfiles/zshrc` (PATH line for `~/.local/share/gem/ruby/3.2.0/bin`), `~/.bundle/config` (`BUNDLE_PATH: /home/mark/.local/share/gem/bundle`).
    - **Known:** gcc/make already present; rake, rspec and all pure-Ruby gems installed; suite green (122 examples) via `GEM_HOME=~/.local/share/gem/bundle/ruby/3.2.0 ~/.local/share/gem/bundle/ruby/3.2.0/bin/rspec`. Failure without headers: `An error occurred while installing prism (1.9.0)` (rubocop 1.88.2 → rubocop-ast 1.50.0 → prism).
    - **Approach:** Mark runs `sudo apt install ruby-dev`, then `bundle install` in the repo, then `bundle exec rspec` and `bundle exec rubocop`.
    - **Done when:** All three commands succeed in a fresh shell with no GEM_HOME tricks; agent memory note `gene-genie-dev-env` updated to drop the "remaining gap" paragraph.

## Doing

## Done
