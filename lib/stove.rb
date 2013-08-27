module Stove
  require_relative 'stove/config'
  require_relative 'stove/git'
  require_relative 'stove/logger'

  require_relative 'stove/cli'
  require_relative 'stove/community_site'
  require_relative 'stove/cookbook'
  require_relative 'stove/error'
  require_relative 'stove/formatter'
  require_relative 'stove/jira'
  require_relative 'stove/mash'
  require_relative 'stove/packager'
  require_relative 'stove/uploader'
  require_relative 'stove/version'

  class << self
    def formatter
      @formatter ||= Stove::Formatter::Human.new
    end

    def set_formatter(name)
      @formatter = Stove::Formatter::Base.formatters[name.to_sym].new
    end
  end
end
