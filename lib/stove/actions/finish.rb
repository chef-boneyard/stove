module Stove
  class Action::Finish < Action::Base
    def run
      log.debug('Running cleanup hooks...')
      log.info('Done!')
    end
  end
end
