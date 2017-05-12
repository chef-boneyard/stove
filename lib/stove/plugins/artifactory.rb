module Stove
  class Plugin::Artifactory < Plugin::Base
    id 'artifactory'
    description 'Publish the release to an Artifactory server'

    validate(:key) do
      Config.artifactory_key && !Config.artifactory_key.strip.empty?
    end

    run('Publishing the release to the Artifactory server') do
      Artifactory.upload(cookbook, options[:extended_metadata])
    end
  end
end
