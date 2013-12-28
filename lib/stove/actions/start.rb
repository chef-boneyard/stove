module Stove
  class Action::Start < Action::Base
    def run
      log.info("Running Stove #{Stove::VERSION} on `#{cookbook.name}'")
    end
  end
end
