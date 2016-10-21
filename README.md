# Stove

[![Gem Version](http://img.shields.io/gem/v/stove.svg?style=flat-square)][gem] [![Build Status](http://img.shields.io/travis/sethvargo/stove.svg?style=flat-square)][travis]

A utility for releasing and managing Chef Cookbooks. It will:

- Tag and push a new release to git
- Upload the cookbook to the Chef Supermarket or a private Supermarket instance

## Why?

Existing tools to package cookbooks (such as [Knife Supermarket](https://github.com/miketheman/knife-supermarket) and `knife cookbook site share`) require a dependency on Chef. Because of their dependency on Chef, they enforce the use of a "cookbook repo". Especially with the evolution of [Berkshelf](https://github.com/berkshelf/berkshelf), cookbooks are individualized artifacts and are often contained in their own repositories. [stove](https://github.com/sethvargo/stove) is **cookbook-centric, rather than Chef-centric**.

## Installation

1. Add Stove to your project's Gemfile:

  ```
  gem 'stove'
  ```

2. Run the `bundle` command to install:

  ```
  $ bundle install --binstubs
  ```

## Configuration

Stove requires your username and private key to upload a cookbook. You can pass these to each command call, or you can set them Stove:

```bash
$ stove login --username sethvargo --key ~/.chef/sethvargo.pem
```

These values will be saved in Stove's configuration file (`~/.stove`) and persisted across your workstation.

The default publishing endpoint is the [Chef Supermarket](https://supermarket.chef.io), but this is configurable. If you want to publish to an internal supermarket, you can specify the `--endpoint` value:

```bash
$ stove --endpoint https://internal-supermarket.example.com/api/v1
```

Please note: depending on which version of Chef and which version of Supermarket you are running, you may support the new "extended" metadata fields. By default, Stove reads but does not write these new fields when uploading cookbooks because it is not backwards compatible. If you are running Chef 12+ and have the latest version of Supermarket installed, you can specify the `--extended-metadata` flag to include these values in the generated metadata:

```bash
$ stove --extended-metadata
```

## Usage

There are two ways to use Stove. You can either use the `stove` command directly or use the embedded rake task.

### Command

Execute the `stove` command from inside the root of a cookbook:

```bash
$ bin/stove
```

This will package (as a tarball) the cookbook in the current working directory, tag a new version, push to git, and publish to a cookbook share.

### Rake task

If you are familiar with the Bundler approach to publishing Ruby gems, this approach will feel very familiar. Simply add the following to your `Rakefile`:

```ruby
require 'stove/rake_task'
Stove::RakeTask.new
```

And then use rake to publish the cookbook:

```bash
$ bin/rake publish
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## See Also

- [Knife Supermarket](https://github.com/miketheman/knife-supermarket)
- [Emeril](https://github.com/fnichol/emeril)

## License & Authors

- Author: Seth Vargo (sethvargo@gmail.com)

```text
Copyright 2013-2016 Seth Vargo <sethvargo@gmail.com>
Copyright 2013-2016 Chef Software, Inc

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

[gem]: https://rubygems.org/gems/stove
[travis]: http://travis-ci.org/sethvargo/stove
