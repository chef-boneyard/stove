module Stove
  class Plugin::Supermarket < Plugin::Base
    id 'supermarket'
    description 'Publish the release to the Chef Supermarket'

    validate(:username) do
      Config.username
    end

    validate(:key) do
      Config.key
    end

    run('Publishing the release to the Chef Supermarket') do
      Supermarket.upload(cookbook, options[:extended_metadata])
    end
  end
end
