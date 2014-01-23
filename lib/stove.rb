require 'pathname'

require 'log4r'
Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)

module Stove
  autoload :Config,     'stove/config'
  autoload :Community,  'stove/community'
  autoload :Cookbook,   'stove/cookbook'
  autoload :Cli,        'stove/cli'
  autoload :Error,      'stove/error'
  autoload :Filter,     'stove/filter'
  autoload :JIRA,       'stove/jira'
  autoload :Mash,       'stove/mash'
  autoload :Packager,   'stove/packager'
  autoload :Runner,     'stove/runner'
  autoload :Util,       'stove/util'
  autoload :Validator,  'stove/validator'
  autoload :VERSION,    'stove/version'

  module Action
    autoload :Base,      'stove/actions/base'
    autoload :Bump,      'stove/actions/bump'
    autoload :Changelog, 'stove/actions/changelog'
    autoload :Dev,       'stove/actions/dev'
    autoload :Finish,    'stove/actions/finish'
    autoload :Start,     'stove/actions/start'
    autoload :Upload,    'stove/actions/upload'
  end

  module Middleware
    autoload :ChefAuthentication, 'stove/middlewares/chef_authentication'
    autoload :Exceptions,         'stove/middlewares/exceptions'
  end

  module Mixin
    autoload :Filterable,   'stove/mixins/filterable'
    autoload :Insideable,   'stove/mixins/insideable'
    autoload :Instanceable, 'stove/mixins/instanceable'
    autoload :Loggable,     'stove/mixins/loggable'
    autoload :Optionable,   'stove/mixins/optionable'
    autoload :Validatable,  'stove/mixins/validatable'
  end

  module Plugin
    autoload :Base,      'stove/plugins/base'
    autoload :Community, 'stove/plugins/community'
    autoload :Git,       'stove/plugins/git'
    autoload :GitHub,    'stove/plugins/github'
    autoload :JIRA,      'stove/plugins/jira'
  end

  #
  # A constant to represent an unset value. +nil+ is too generic and doesn't
  # allow users to specify a value as +nil+. Using this constant, we can
  # safely create +set_or_return+-style methods.
  #
  # @return [Object]
  #
  UNSET_VALUE = Object.new

  #
  # The User-Agent to use for HTTP requests
  #
  # @return [String]
  #
  USER_AGENT = "Stove #{VERSION}"

  class << self
    #
    # The source root of the ChefAPI gem. This is useful when requiring files
    # that are relative to the root of the project.
    #
    # @return [Pathname]
    #
    def root
      @root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    #
    # The current log level for the entire application.
    #
    # @return [Integer]
    #
    def log_level
      Log4r::Logger.global.level
    end

    #
    # Set the global log level.
    #
    # @example Set the log level to warn
    #   Stove.log_level = :warn
    #
    # @param [String, Symbol] id
    #   the log level to set
    #
    def log_level=(id)
      level = Log4r.const_get(id.to_s.upcase)
      raise NameError unless level.is_a?(Integer)

      Log4r::Logger.global.level = level
    rescue NameError
      $stderr.puts "ERROR `#{id}' is not a valid Log Level!"
    end
  end
end

require 'i18n'
I18n.enforce_available_locales = true
I18n.load_path << Dir[Stove.root.join('locales', '*.yml').to_s]
