Feature: Changelog
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon"

  Scenario: When the Changelog does not exist
    * I remove the file "CHANGELOG.md"
    * I run `bake --changelog`
    * it should fail with "There is no `CHANGELOG.md' found"

  Scenario: When the Changelog is not a proper format
    * I write to "CHANGELOG.md" with:
      """
      This can't possibly be a valid Changelog
      """
    * I run `bake --changelog`
    * it should fail with "does not appear to be a valid format"

  Scenario: When the $EDITOR is not set
    * the environment variable "EDITOR" is unset
    * I run `bake --changelog`
    * it should fail with "The `$EDITOR' environment variable is not set"

  Scenario: In isolation
    * the environment variable "EDITOR" is "cat"
    * I successfully run `bake --changelog`
    * the file "CHANGELOG.md" should contain "v0.0.0"

  Scenario: With bump
    * the environment variable "EDITOR" is "cat"
    * I successfully run `bake 1.0.0 --changelog --bump`
    * the file "CHANGELOG.md" should contain "v1.0.0"

  Scenario: With a hyphenated cookbook name
    * I have a cookbook named "bacon-maple-bars"
    * the environment variable "EDITOR" is "cat"
    * I successfully run `bake 1.0.0 --changelog --bump`
    * the file "CHANGELOG.md" should contain "bacon-maple-bars Changelog"
    * the file "CHANGELOG.md" should contain "v1.0.0"

  Scenario: With the git plugin
    * I have a cookbook named "bacon" with git support
    * the environment variable "EDITOR" is "cat"
    * I successfully run `bake --changelog --git`
    * the git remote should have the commit "Publish 0.0.0 Changelog"

  @wip
  Scenario: With the GitHub plugin

  @wip
  Scenario: With the JIRA plugin
