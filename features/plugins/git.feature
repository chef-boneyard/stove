Feature: git Plugin
  Background:
    * I have a cookbook named "bacon"
    * the supermarket has the cookbooks:
      | bacon | 1.0.0 |

  Scenario: When the directory is not a git repository
    * I run `stove`
    * it should fail with "does not appear to be a valid git repository"

  Scenario: When the directory is dirty
    * I have a cookbook named "bacon" with git support
    * I write to "new" with:
     """
     This is new content
     """
    * I run `stove`
    * it should fail with "has untracked files"

  Scenario: When the local is out of date with the remote
    * I have a cookbook named "bacon" with git support
    * the remote repository has additional commits
    * I run `stove -l debug`
    * it should fail with "out of sync with the remote repository"

  Scenario: When a git upload should be done
    * I have a cookbook named "bacon" with git support
    * I successfully run `stove`
    * the git remote should have the tag "v0.0.0"

  Scenario: When using signed tags
    * I have a cookbook named "bacon" with git support
    * a GPG key exists
    * I successfully run `stove --sign`
    * the git remote should have the signed tag "v0.0.0"

  Scenario: With the git plugin disabled
    * I have a cookbook named "bacon" with git support
    * I successfully run `stove --no-git`
    * the git remote should not have the tag "v0.0.0"
