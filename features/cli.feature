Feature: Cli
  Background:
    * I have a cookbook named "bacon"

  Scenario: no version
    * I run `bake`
    * the exit status will be "InvalidVersionError"

  Scenario: invalid version
    * I run `bake 1.2`
    * the exit status will be "InvalidVersionError"
