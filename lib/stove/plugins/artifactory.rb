require 'net/https'

module Stove
  class Plugin::Artifactory < Plugin::Base
    id 'artifactory'
    description 'Publish the release to an Artifactory server'

    validate(:credentials) do
      if Config.artifactory_key
        !Config.artifactory_key.strip.empty?
      else
        url = URI.parse(Config.artifactory.strip)
        url.user and url.password and url.scheme == 'https'
      end
    end

    run('Publishing the release to the Artifactory server') do
      Artifactory.upload(cookbook, options[:extended_metadata])
    end
  end
end
