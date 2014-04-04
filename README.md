Stove
=====
[![Gem Version](http://img.shields.io/gem/v/stove.svg)][gem]
[![Build Status](http://img.shields.io/travis/sethvargo/stove.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/sethvargo/stove.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/sethvargo/stove.svg)][codeclimate]
[![Gittip](http://img.shields.io/gittip/sethvargo.svg)][gittip]

[gem]: https://rubygems.org/gems/stove
[travis]: http://travis-ci.org/sethvargo/stove
[gemnasium]: https://gemnasium.com/sethvargo/stove
[codeclimate]: https://codeclimate.com/github/sethvargo/stove
[gittip]: https://www.gittip.com/sethvargo

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

The use of some plugins (such as GitHub and JIRA) require a Stove configuration file. The Stove config is a JSON file stored at `~/.stove` on your local hard drive. The schema looks like this:

```javascript
{
  "field": {
    "option": "value"
  }
}
```

For example, my local Stove configuration looks like this:

```javascript
{
  "community": {
    "username": "sethvargo",
    "key": "~/.chef/sethvargo.pem"
  },
  "github": {
    "access_token": "..."
  },
  "jira": {
    "username": "sethvargo",
    "password": "..."
  }
}
```

If you are using Stove 1.0, you need to update your configuration file syntax.

**It is recommended that the permissions on this file be 0600 to prevent unauthorized reading!**


Usage
-----
The gem is packaged as a binary. It should be run from _inside the cookbook to release_:

    (~/cookbooks/bacon) $ bake 1.2.3

You can always use the `--help` flag to get information:

```text
Usage: bake x.y.z

Actions:
        --[no-]bump                  [Don't] Perform a version bump the local version automatically
        --[no-]changelog             [Don't] Generate and prompt for a CHANGELOG
        --[no-]dev                   [Don't] Bump a minor version release for development purposes
        --[no-]upload                [Don't] Execute upload stages of enabled plugins

Plugins:
        --[no-]community             [Don't] Upload to the community site
        --[no-]git                   [Don't] Tag and push to a git remote
        --[no-]github                [Don't] Publish the release to GitHub
        --[no-]jira                  [Don't] Resolve JIRA issues

Global Options:
        --locale [LANGUAGE]          Change the language to output messages
        --log-level [LEVEL]          Set the log verbosity
        --category [CATEGORY]        Set category for the cookbook
        --path [PATH]                Change the path to a cookbook
        --remote [REMOTE]            The name of the git remote to push to
        --branch [BRANCH]            The name of the git branch to push to
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
