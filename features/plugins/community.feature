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

  Scenario: Yanking a cookbook
    * the supermarket has the cookbooks:
      | bacon | 1.2.3 |
    * I successfully run `stove yank -l debug`
    * the supermarket will not have the cookbooks:
      | bacon | 1.2.3 |
    * the output should contain "Successfully yanked bacon!"

  Scenario: Yanking a cookbook by name
    * the supermarket has the cookbooks:
      | eggs | 4.5.6 |
    * I successfully run `stove yank eggs`
    * the supermarket will not have the cookbooks:
      | eggs | 4.5.6 |
    * the output should not contain "Successfully yanked bacon!"
    * the output should contain "Successfully yanked eggs!"

  Scenario: Yanking a non-existent cookbook
    * I run `stove yank ham`
    * it should fail with "I could not find a cookbook named ham"
