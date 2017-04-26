require 'rspec'
require 'webmock/rspec'
require 'rspec_command'
require 'stove'

RSpec.configure do |config|
  # Chef Server
  require 'support/generators'
  config.include(Stove::RSpec::Generators)

  # Basic configuraiton
  config.run_all_when_everything_filtered = true
  config.filter_run(:focus) unless ENV['CI']

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Don't try running the Artifactory integration tests without the config for it.
  # See integration/artifactory_spec for more info.
  config.filter_run_excluding(:artifactory_integration) unless ENV['TEST_STOVE_ARTIFACTORY']
end

def tmp_path
  @tmp_path ||= Pathname.new(File.expand_path('../../tmp', __FILE__))
end
