Feature: Git
  Background:
    * the CLI options are all off

  Scenario: --no-git
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake 1.0.0 --no-git`
    * the git remote will not have the commit "Version bump to v1.0.0"
    * the git remote will not have the tag "v1.0.0"

  Scenario: --git
    * I have a cookbook named "bacon" with git support
    * I successfully run `bake 1.0.0 --git`
    * the git remote will have the commit "Version bump to v1.0.0"
    * the git remote will have the tag "v1.0.0"

  Scenario: A dirty git repo
    * I have a cookbook named "bacon" with git support
    * I append to "CHANGELOG.md" with "# A change"
    * I run `bake 1.0.0 --git`
    * the git remote will not have the commit "Version bump to v1.0.0"
    * the git remote will not have the tag "v1.0.0"
    * the exit status will be "GitError::DirtyRepo"

  Scenario: Not a git repo
    * I have a cookbook named "bacon"
    * I run `bake 1.0.0 --git`
    * the exit status will be "GitError::NotARepo"

  Scenario: Remote repository out of sync
    * I have a cookbook named "bacon" with git support
    * the remote repository has additional commits
    * I run `bake 1.0.0 --git`
    * the exit status will be "GitError::OutOfSync"
