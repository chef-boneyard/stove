#!/bin/bash
#
# This script runs a passed in command, but first setups up the bundler caching on the repo

set -e

export USER="root"

# make sure we have the aws cli
apt-get update -y
apt-get install awscli -y

git config --global user.email "foo@example.com"
git config --global user.name "Foo Bar"

bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3
echo "bundle exec task"
bundle exec $1
