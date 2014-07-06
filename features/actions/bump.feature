Feature: Bump
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon" at version "1.0.0"

  Scenario: When the version has not changed
    * I run `bake 1.0.0 --bump`
    * it should fail with "version you are trying to bump already exists"

  Scenario: When the version is not greater than the current
    * I run `bake 0.1.0 --bump`
    * it should fail with "bump to is less than the existing version"

  Scenario: In isolation
    * I successfully run `bake 2.0.0 --bump`
    * the file "metadata.rb" should contain "2.0.0"
    * the file "metadata.rb" should not contain "# development version"

  Scenario: With the git plugin
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake 1.0.0 --bump --git`
    * the git remote should have the commit "Version bump to 1.0.0"
