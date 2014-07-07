Stove CHANGELOG
===============
This is the Changelog for the Stove gem.

v3.0.0 (2014-07-07)
-------------------
- Add support for signed git tags
- Require Ruby 1.9+
- Remove i18n in favor of ERB
- Remove solve gem
- Remove GitHub functionality
- Remove JIRA functionality
- Remove bump and devodd functionality
- Clear up confusion on Gemfile vs not Gemfile
- Always read tarball objects as binary
- End tempfiles in the correct extension (needed to detect mime_types)
- Bump required version of ChefAPI gem
- Remove unused errors and code
- Improved documentation
- Remove editor files (`.swp`, etc) before packaging
- Upgrade to RSpec 3
- Improve test coverage
- Publish to Supermarket by default

v2.0.0 (2014-04-04)
-------------------
- Completely refactor the runner for speed optimizations
- Introduce a new configuration file format
- Add i18n support
- Add Filters and validations that execute before any commands are run
- Autoload plugins and actions
- Improve help output by grouping options
- Trap Signal interrupts cleanly
- Remove formatters
- Switch to logify
- Introduce significantly more logging and log levels
- Remove HTTParty & Jiralicious in favor or Faraday
- Improve rake task to automatically perfom a minor bump when no version if given
- Persist data across the cookbook object
- Use singleton classes to save memory and loadtime

v1.1.0
------
- Check if the git remote is in sync with local branch before pushing
- Add support for bumping devodd releases
- Add a custom rake task
- Add ability to publish GitHub releases
- Fix CLI bug that didn't allow options to parse
- Add logging during release process
- Fix error where the community site does not give an adequate response
- Retry uploads 3 times in case the community site is being lame

v1.0.1
------
- Fix a bug where `--log-level` was being ignored

v1.0.0
------
- Initial release
