# Stove CHANGELOG

This is the Changelog for the Stove gem.

## v6.0.0

### Breaking Changes

- All references to the Community site have been renamed to Supermarket. This includes the name of the `community` plugin and all `Community` classes references within the code. This should not be a breaking change unless your developing against stove as a library.
- The long ago deprecated `bake` command has been removed.

### Other Changes

- Git tagging errors now include more useful error messaging.
- The help command now better describes `--no-git` and `--endpoint` flags.
- For developers running stove from the git repository, the application now properly loads stove from the repository instead of from an installed gem.

## v5.2.0 (2017-05-12)

- Support for uploading to Artifactory

## v5.1.0 (2017-03-31)

- Match Chef's metadata behavior with chef_version and ohai_version to allow version constraints like '>= 12.5', '< 14'
- Allow having gem version in cookbook metadata.json
- Better align gem version logic with how Chef handles it

## v5.0.0 (2017-03-22)

- Enable pushing extended metadata for Chef 12 by default
- Add gem metadata to the extended metadata whitelist
- Use git porcelain vs. -s to avoid having local git configs interfere with stove functionality
- Only populate the extended metadata if the fields are actually present in the metadata
- Support for Ruby 2.0 has been dropped as Ruby 2.0 has been EOL'd

## v4.1.1 (2016-06-02)

- Don't delete the metadata.json file if there isn't a metadata.rb

## v4.1.0 (2016-06-02)

- Support uploading cookbooks to Supermarket that lack a metadata.rb, but have a metadata.json

## v4.0.0 (2016-05-05)

- This version of stove now requires Ruby 2.0 or later

## v3.2.8 (2015-11-19)

- Add endpoint config to the .stove config file for users of private Supermarkets
- Add option --no-ssl-verify to skip SSL verification
- Add chef_version and ohai_version metadata when extended-metadata is enabled
- Add CONTRIBUTING.md, MAINTAINERS.md and .foodcritic to the file whitelist

## v3.2.7 (2015-04-16)

- Use chef.io instead of getchef.com
- Ignore `vendor/` directory
- Do not publish extended metadata fields like `issues_url` and `source_url` by default (GH-64, GH-72). These fields can be optionally added using the new `--extended-metadata` flag.
- Add support for Ruby 2.2
- Use binmode when reading and writing the tgz (GH-64)

## v3.2.6 (2015-03-18)

- Include new metadata methods for Supermarket

## v3.2.5 (2014-12-19)

- Fix a bug with line endings when generating tarballs

## v3.2.4 (2014-12-07)

- Add support for `issues_url` and `source_url` metadata attributes

## v3.2.3 (2014-10-12)

- Only upload fully-compiled metadata (i.e. only upload metadata.json, not metadata.rb)

## v3.2.2 (2014-08-07)

- Fix a bug where files beginning with a dot (`.`) were not packaged

## v3.2.1 (2014-07-16)

- Fix a critical bug where nested directories are flattened

## v3.2.0 (2014-07-15)

**This version has been removed from Rubygems**

- Add the ability to "yank" (delete) a cookbook from the Supermarket
- Remove the `--category` flag (it is no longer honored)
- Fix a bug where the `resources/` folder was not uploaded
- Fix a bug when the cookbook name is not the same as the metdata name in the uploaded tarball

## v3.1.0 (2014-07-10)

**This version has been removed from Rubygems**

- Use the generated tempfile directly (instead of writing to disk and creating File objects)
- Add a default version constraint ('>= 0.0.0')
- Only package Ruby files under `recipes/` and similar directories
- Dynamically generate the metadata.json in memory (save disk IO)
- Use Rubygem's TarWrtier instead of minitar (removed dependency)
- Bump version of Chef API to support tempfile IO objects

## v3.0.0 (2014-07-07)

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

## v2.0.0 (2014-04-04)

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

## v1.1.0

- Check if the git remote is in sync with local branch before pushing
- Add support for bumping devodd releases
- Add a custom rake task
- Add ability to publish GitHub releases
- Fix CLI bug that didn't allow options to parse
- Add logging during release process
- Fix error where the community site does not give an adequate response
- Retry uploads 3 times in case the community site is being lame

## v1.0.1

- Fix a bug where `--log-level` was being ignored

## v1.0.0

- Initial release
