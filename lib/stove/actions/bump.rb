module Stove
  class Action::Bump < Action::Base
    id 'bump'
    description 'Perform a version bump the local version automatically'

    validate(:changed) do
      cookbook.version != options[:version]
    end

    validate(:incremented) do
      version = Gem::Version.new(options[:version].dup)
      Gem::Requirement.new("> #{cookbook.version}").satisfied_by?(version)
    end

    def run
      log.info('Performing version bump')
      log.debug("Version is currently #{cookbook.version}")
      log.debug("Bumped version is #{options[:version]}")

      cookbook.bump(options[:version])

      log.debug("Version is now #{cookbook.version}")
    end
  end
end
