require 'stove'

require 'aruba'
require 'aruba/cucumber'
require 'aruba/in_process'

Aruba::InProcess.main_class = Stove::Cli
Aruba.process = Aruba::InProcess

require 'community_zero/rspec'
CommunityZero::RSpec.start

require File.expand_path('../stove/git', __FILE__)

World(Aruba::Api)
World(Stove::Git)

Before do
  CommunityZero::RSpec.reset!

  Stove::Config.endpoint = CommunityZero::RSpec.url
  Stove::Config.username = 'stove'
  Stove::Config.key      = File.expand_path('../stove.pem', __FILE__)
end

Before do
  FileUtils.rm_rf(scratch_dir)
  FileUtils.mkdir_p(scratch_dir)
end

# The scratch directory
def scratch_dir
  @scratch_dir ||= File.expand_path('tmp/aruba/scratch')
end
