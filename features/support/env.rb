require 'aruba/api'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'rspec/expectations'
require 'stove'

require_relative '../../spec/support/community_site'
require_relative '../../spec/support/git'

World(Aruba::Api)
World(Stove::RSpec::Git)

Stove.set_formatter(:silent)
Stove::Config.instance_variable_set(:@instance, {
  'jira_username'    => 'default',
  'jira_password'    => 'default',
  'opscode_username' => 'stove',
  'opscode_pem_file' => File.expand_path(File.join(__FILE__, '..', 'stove.pem')),
})
Stove::RSpec::CommunitySite.start(port: 3390)
Stove::CommunitySite.base_uri(Stove::RSpec::CommunitySite.server_url)
Stove::CommunitySite.http_uri(Stove::RSpec::CommunitySite.server_url)

Before do
  @dirs = [Dir.mktmpdir]
  Stove::RSpec::CommunitySite.reset!
end

Before('~@spawn') do
  Aruba::InProcess.main_class = Stove::Cli
  Aruba.process = Aruba::InProcess
end

Before('@spawn') do
  Aruba.process = Aruba::SpawnProcess
end

# The path to Aruba's "stuff"
def tmp_path
  File.expand_path(@dirs.first.to_s)
end
