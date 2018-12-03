Feature: Supermarket
  Background:
    * I have a cookbook named "bacon"

  Scenario: When the username does not exist
    * the Stove config at "username" is unset
    * I run `stove --no-git`
    * it should fail with "requires a username"

  Scenario: When the key does not exist
    * the Stove config at "key" is unset
    * I run `stove --no-git`
    * it should fail with "requires a private key"

  Scenario: With the default parameters
    * the supermarket has the cookbook:
      | bacon | 1.2.3 |
    * I successfully run `stove --no-git`
    * the supermarket will have the cookbooks:
      | bacon | 0.0.0 |
