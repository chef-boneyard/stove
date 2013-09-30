Feature: Upload
  Background:
    * I have a cookbook named "bacon"
    * the CLI options are all off

  Scenario: --no-upload
    * I successfully run `bake 1.0.0 --no-upload`
    * the Community Site will not have the cookbook:
      | bacon | 1.0.0 |

  Scenario: --upload (no category, no existing)
    * I run `bake 1.0.0 --upload`
    * the Community Site will not have the cookbook:
      | bacon | 1.0.0 |
    * the exit status will be "CookbookCategoryNotFound"

  Scenario: --upload (no category, existing)
    * the Community Site has the cookbook:
      | bacon | 0.0.0 | Application |
    * I successfully run `bake 1.0.0 --upload`
    * the Community Site will have the cookbook:
      | bacon | 1.0.0 | Application |

  Scenario: --upload (category, no existing)
    * I successfully run `bake 1.0.0 --upload --category Application`
    * the Community Site will have the cookbook:
      | bacon | 1.0.0 | Application |

  Scenario: --upload (category, existing)
    * the Community Site has the cookbook:
      | bacon | 0.0.0 | Application |
    * I successfully run `bake 1.0.0 --upload --category Application`
    * the Community Site will have the cookbook:
      | bacon | 1.0.0 | Application |

  Scenario: --upload (existing version)
    * the Community Site has the cookbook:
      | bacon | 1.0.0 | Application |
    * I run `bake 1.0.0 --upload`
    * the exit status will be "UploadError"
