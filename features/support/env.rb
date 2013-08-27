require 'aruba/api'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'rspec/expectations'
require 'stove'

require_relative '../../spec/support/community_site'
require_relative '../../spec/support/git'

World(Aruba::Api)
World(Stove::RSpec::Git)

Aruba::InProcess.main_class = Stove::Cli
Aruba.process = Aruba::InProcess

Stove.set_formatter(:silent)
Stove::RSpec::CommunitySite.start(port: 3390)
Stove::CommunitySite.base_uri(Stove::RSpec::CommunitySite.server_url)
Stove::CommunitySite.http_uri(Stove::RSpec::CommunitySite.server_url)

Before do
  @dirs = [Dir.mktmpdir]
  Stove::RSpec::CommunitySite.reset!
end

# The path to Aruba's "stuff"
def tmp_path
  File.expand_path(@dirs.first.to_s)
end
