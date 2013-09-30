Stove
=====
[![Gem Version](https://badge.fury.io/rb/stove.png)](http://badge.fury.io/rb/stove)
[![Build Status](https://travis-ci.org/sethvargo/stove.png?branch=master)](https://travis-ci.org/sethvargo/stove)
[![Dependency Status](https://gemnasium.com/sethvargo/stove.png)](https://gemnasium.com/sethvargo/stove)
[![Code Climate](https://codeclimate.com/github/sethvargo/stove.png)](https://codeclimate.com/github/sethvargo/stove)

A utility for releasing and managing Chef Cookbooks. It will:

- Edit the `metadata.rb` and insert the proper version
- Create a CHANGELOG from JIRA tickets
- Commit and push these changes to git
- Create a git tag and push those changes to git
- Publish a release to GitHub releases
- Upload the cookbook to the Opscode Community Site
- Resolve (close) the JIRA tickets


Why?
----
Existing tools to package cookbooks (such as [Knife Community](https://github.com/miketheman/knife-community) and `knife cookbook site share`) require a dependency on Chef. Because of thier dependency on Chef, they enforce the use of a "cookbook repo". Especially with the evolution of [Berkshelf](https://github.com/RiotGames/berkshelf), cookbooks are individualized artifacts and are often contained in their own repositories. [stove](https://github.com/sethvargo/stove) is **cookbook-centric, rather than Chef-centric**. Since all commands are run from inside the cookbook, it's safe to include stove in your cookbooks `Gemfile`.


Installation
------------
It is highly recommended that you include `stove` in your cookbook's Gemfile:

```ruby
gem 'stove'
```

Alternatively, you may install it as a gem:

    $ gem install stove

Create a special JIRA credentials file at '~/.stove' that has the following JSON:

```javascript
{
  "jira_username": "JIRA_USERNAME",
  "jira_password": "JIRA_PASSWORD",
  "opscode_username": "OPSCODE_USERNAME",
  "opscode_pem_file": "OPSCODE_PEM_FILE",
  "github_access_token": "PERSONAL_API_TOKEN"
}
```

- `jira_username` - The username used to login to Opscode's JIRA
- `jira_password` - The password used to login to Opscode's JIRA
- `opscode_username` - The username used to login to Opscode's Community Site
- `opscode_password` - The password used to login to Opscode's Community Site
- `github_access_token` - Your personal access token for the GitHub API

For example:

```javascript
{
  "jira_username": "sethvargo",
  "jira_password": "bAc0ñ",
  "opscode_username": "sethvargo",
  "opscode_pem_file": "~/.chef/sethvargo.pem",
  "github_access_token": "abcdefg1234567"
}
```


Usage
-----
The gem is packaged as a binary. It should be run from _inside the cookbook to release_:

    (~/cookbooks/bacon) $ bake 1.2.3

```text
Usage: bake x.y.z
    -l, --log-level [LEVEL]          Ruby log level
    -c, --category [CATEGORY]        The category for the cookbook (optional for existing cookbooks)
    -p, --path [PATH]                The path to the cookbook to release (default: PWD)
        --[no-]git                   Automatically tag and push to git (default: true)
        --[no-]github                Automatically release to GitHub (default: true)
    -r, --remote                     The name of the git remote to push to
    -b, --branch                     The name of the git branch to push to
        --[no-]devodd                Automatically bump the metadata for devodd releases
        --[no-]jira                  Automatically populate the CHANGELOG from JIRA tickets and close them (default: false)
        --[no-]upload                Upload the cookbook to the Opscode Community Site (default: true)
        --[no-]changelog             Automatically generate a CHANGELOG (default: true)
    -h, --help                       Show this message
    -v, --version                    Show version
```


Rake Task
---------
Stove also includes a Rake task you can include in your Rakefile:

```ruby
require 'stove/rake_task'

Stove::RakeTask.new do |stove|
  stove.git = true
  stove.devodd = true
end
```


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

TODO:
- Secure the authentication file


See Also
--------
- [Knife Community](https://github.com/miketheman/knife-community)
- [Emeril](https://github.com/fnichol/emeril)


License & Authors
-----------------
- Author: Seth Vargo (sethvargo@gmail.com)

```text
Copyright 2013 Seth Vargo <sethvargo@gmail.com>
Copyright 2013 Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
