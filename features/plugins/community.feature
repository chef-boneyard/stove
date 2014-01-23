Feature: Community
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon"
    * I am using the community server

  Scenario: When the configuration does not exist
    * I run `bake --upload --community`
    * it should fail with "configuration for the Chef community site does not exist"

  Scenario: When the username does not exist
    * the Stove config at "community._" is ""
    * I run `bake --upload --community`
    * it should fail with "does not contain a username"

  Scenario: When the key does not exist
    * the Stove config at "community.username" is "bobo"
    * I run `bake --upload --community`
    * it should fail with "does not contain a key"

  Scenario: When the category does not exist
    * the Stove config at "community.username" is "bobo"
    * the Stove config at "community.key" is "../../features/support/stove.pem"
    * I run `bake --upload --community`
    * it should fail with "You did not specify a category"

  Scenario: In isolation
    * the Stove config at "community.username" is "bobo"
    * the Stove config at "community.key" is "../../features/support/stove.pem"
    * the community server has the cookbook:
      | bacon | 1.2.3 | Application |
    * I successfully run `bake --upload --community`

  Scenario: When the community plugin is explicitly disabled
    * the Stove config at "community.username" is "bobo"
    * the Stove config at "community.key" is "../../features/support/stove.pem"
    * I successfully run `bake --upload --no-community`
    * the community server will not have the cookbook:
      | bacon | | |
