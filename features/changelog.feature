Feature: Changelog
  Background:
    * the CLI options are all off
    * I have a cookbook named "bacon"

  Scenario: --no-changelog
    * I successfully run `bake 1.0.0 --no-changelog`

  Scenario: --changelog
    * the environment variable EDITOR is "cat"
    * I successfully run `bake 1.0.0 --changelog`
    * the file "CHANGELOG.md" should contain:
      """
      v1.0.0
      ------
      _Enter CHANGELOG for bacon (1.0.0) here_
      """

  Scenario: bad $EDITOR
    * the environment variable EDITOR is "not-a-real-shell-command"
    * I run `bake 1.0.0 --changelog`
    * the exit status will be "Error"
