module Stove
  class Action::Dev < Action::Base
    id 'dev'
    description 'Bump a minor version release for development purposes'

    def run
      log.info('Bumping for development release')
      log.debug("Version is currently #{cookbook.version}")
      log.debug("Bumped version is #{dev_version}")

      cookbook.bump(dev_version, 'development version')

      log.debug("Version is now #{cookbook.version}")
    end

    def dev_version
      split = cookbook.version.split('.').map(&:to_i)
      split[2] += 1
      split.join('.')
    end
  end
end
