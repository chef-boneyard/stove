module Stove
  class Plugin::Community < Plugin::Base
    id 'community'
    description 'Publish the release to the Chef community site'

    validate(:configuration) do
      Config.has_key?(:community)
    end

    validate(:username) do
      Config[:community].has_key?(:username)
    end

    validate(:key) do
      Config[:community].has_key?(:key)
    end

    validate(:category) do
      !cookbook.category.nil?
    end

    after(:upload, 'Publishing the release to the Chef community site') do
      Community.upload(cookbook)
    end
  end
end
