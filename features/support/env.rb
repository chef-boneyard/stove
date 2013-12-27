require 'bundler/setup'

require 'aruba/api'
require 'aruba/cucumber'
require 'cucumber/rspec/doubles'
require 'rspec/expectations'

require 'community_zero/rspec'
CommunityZero::RSpec.start
Before { CommunityZero::RSpec.reset! }

require 'stove'

require File.expand_path('../stove/git', __FILE__)

World(Aruba::Api)
World(Stove::Git)

Before do
  FileUtils.rm_rf(tmp_path)
  @aruba_timeout_seconds = 15
end

# The path to Aruba's "stuff"
def tmp_path
  File.expand_path(@dirs.first.to_s)
end
