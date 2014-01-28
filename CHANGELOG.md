Stove CHANGELOG
===============
This is the Changelog for the Stove gem.

v2.0.0 (unreleased)
-------------------
- Completely refactor the runner for speed optimizations
- Introduce a new configuration file format
- Add i18n support
- Add Filters and validations that execute before any commands are run
- Autoload plugins and actions
- Improve help output by grouping options
- Trap Signal interrupts cleanly
- Remove formatters
- Switch to log4r
- Introduce significantly more logging and log levels
- Remove HTTParty & Jiralicious in favor or Faraday
- Improve rake task to automatically perfom a minor bump when no version if given
- Persist data across the cookbook object
- Use singleton classes to save memory and loadtime
- Force a non-broken version of log4r

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
