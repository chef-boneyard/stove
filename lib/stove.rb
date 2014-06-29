require 'logify'
require 'pathname'

module Stove
  autoload :Config,     'stove/config'
  autoload :Community,  'stove/community'
  autoload :Cookbook,   'stove/cookbook'
  autoload :Cli,        'stove/cli'
  autoload :Error,      'stove/error'
  autoload :Filter,     'stove/filter'
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
    autoload :Optionable,   'stove/mixins/optionable'
    autoload :Validatable,  'stove/mixins/validatable'
  end

  module Plugin
    autoload :Base,      'stove/plugins/base'
    autoload :Community, 'stove/plugins/community'
    autoload :Git,       'stove/plugins/git'
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
    # Set the log level.
    #
    # @example Set the log level to :info
    #   ChefAPI.log_level = :info
    #
    # @param [Symbol] level
    #   the log level to set
    #
    def log_level=(level)
      Logify.level = level
    end

    #
    # Get the current log level.
    #
    # @return [Symbol]
    #
    def log_level
      Logify.level
    end
  end
end
