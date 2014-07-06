Feature: Dev
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon" at version "1.0.0"

  Scenario: In isolation
    * I successfully run `bake --dev`
    * the file "metadata.rb" should contain "1.0.1"

  Scenario: With bump
    * I successfully run `bake 2.0.0 --bump --dev`
    * the file "metadata.rb" should contain "2.0.1"
    * the file "metadata.rb" should match /^version .* # development version$/

  Scenario: With the git plugin
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake --dev --git`
    * the git remote should have the commit "Version bump to 0.0.1 (for development)"
