Feature: Upload
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon"
    * I am using the community server

  Scenario: With the git plugin
    * I have a cookbook named "bacon" with git support
    * the Stove config at "community.username" is "bobo"
    * the Stove config at "community.key" is "../../features/support/stove.pem"
    * the community server has the cookbook:
      | bacon | 1.2.3 | Application |
    * I successfully run `bake --git --upload --community`
    * the git remote should have the tag "v0.0.0"

  Scenario: With the git plugin and the upload action disabled
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake --git --no-upload`
    * the git remote should not have the tag "v0.0.0"

  @wip
  Scenario: With the GitHub plugin

  @wip
  Scenario: With the JIRA plugin
