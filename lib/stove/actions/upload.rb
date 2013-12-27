module Stove
  class Action::Upload < Action::Base
    id 'upload'
    description 'Upload the cookbook to the community site'

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

    def run
      log.info('Uploading to the Chef community site')
      Community.upload(cookbook)
    end
  end
end
