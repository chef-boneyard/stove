Feature: Devodd
  Background:
    * the CLI options are all off
    * I have a cookbook named "bacon"

  Scenario: --no-devodd
    * I successfully run `bake 1.0.0 --no-devodd`

  Scenario: --devodd
    * I successfully run `bake 1.0.0 --devodd`
    * the file "metadata.rb" should contain:
      """
      version '1.0.1'
      """

  Scenario: --git --devodd
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake 1.0.0 --devodd --git`
    * the git remote will have the commit "Version bump to v1.0.1"
