# Ruby

Use rvm, not the system Ruby (2.6) or Homebrew’s. Before any `bundle` or `jekyll` command, run `source ~/.rvm/scripts/rvm && rvm use .`, which picks the version from `.ruby-version`. Don’t run a plain `bundle install` or `bundle update` under another Ruby: it re-resolves and downgrades `Gemfile.lock` (github-pages 232 to 223, activesupport 8.1 to 3.2).
