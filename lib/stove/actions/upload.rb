module Stove
  class Action::Upload < Action::Base
    id 'upload'
    description 'Publish the release to enabled plugin destinations'

    def run
      log.debug('Running upload hooks...')
      log.info('Done!')
    end
  end
end
