module Stove
  class Plugin::Community < Plugin::Base
    id 'community'
    description 'Publish the release to the Chef community site'

    validate(:username) do
      Config.username
    end

    validate(:key) do
      Config.key
    end

    validate(:category) do
      !cookbook.category.nil?
    end

    run('Publishing the release to the Chef community site') do
      Community.upload(cookbook)
    end
  end
end
