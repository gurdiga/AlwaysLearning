# Ruby

Use rvm, not the system Ruby (2.6) or Homebrew’s. `.ruby-version` pins 3.4.8, which rvm has installed. Before any `bundle` or `jekyll` command, run `source ~/.rvm/scripts/rvm && rvm use 3.4.8`. Don’t run a plain `bundle install` or `bundle update` under another Ruby: it re-resolves and downgrades `Gemfile.lock` (github-pages 232 to 223, activesupport 8.1 to 3.2).
