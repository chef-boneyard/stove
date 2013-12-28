Feature: git Plugin
  Background:
    * the Stove config is empty
    * the CLI options are all off
    * I have a cookbook named "bacon"

  Scenario: When the directory is not a git repository
    * I run `bake --git`
    * it should fail with "does not appear to be a valid git repository"

  Scenario: When the directory is dirty
    * I have a cookbook named "bacon" with git support
    * I write to "new" with:
     """
     This is new content
     """
    * I run `bake --git`
    * it should fail with "has untracked files"

  Scenario: When the local is out of date with the remote
    * I have a cookbook named "bacon" with git support
    * the remote repository has additional commits
    * I run `bake --git`
    * it should fail with "out of sync with the remote repository"
