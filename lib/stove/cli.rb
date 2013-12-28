require 'optparse'
require 'stove'

module Stove
  class Cli
    include Mixin::Loggable

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      $stdout, $stderr = @stdout, @stderr

      # Parse the options hash
      option_parser.parse!(@argv)

      # Parse out the version from ARGV
      options[:version] = @argv.shift

      # Useful debugging output for when people type the wrong fucking command
      # and then open an issue like it's somehow my fault
      log.info("Options: #{options.inspect}")
      log.info("ARGV: #{@argv.inspect}")

      # Unless the user specified --no-bump, version is a required argument, so
      # blow up if we don't get it or if it's not a nice version string
      if options[:bump]
        raise OptionParser::MissingArgument.new(:version) unless options[:version]
      end

      # Make a new cookbook object - this will raise an exception if there is
      # no cookbook at the given path
      cookbook = Cookbook.new(options[:path])

      # Now execute the actual runners (validations and errors might occur)
      Runner.run(cookbook, options)

      # If we got this far, everything was successful :)
      @kernel.exit(0)
    rescue => e
      log.error('Stove experienced an error!')
      log.error(e.class.name)
      log.error(e.message)
      log.error(e.backtrace.join("\n"))

      @kernel.exit(e.respond_to?(:exit_code) ? e.exit_code : 500)
    ensure
      $stdout, $stderr = STDOUT, STDERR
    end

    private

    #
    # The option parser for handling command line flags.
    #
    # @return [OptionParser]
    #
    def option_parser
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = 'Usage: bake x.y.z'

        opts.separator ''
        opts.separator 'Actions:'

        actions = Action.constants.map(&Action.method(:const_get))
        actions.select(&:id).each do |action|
          opts.on("--[no-]#{action.id}", action.description) do |v|
            options[action.id.to_sym] = v
          end
        end

        opts.separator ''
        opts.separator 'Plugins:'

        plugins = Plugin.constants.map(&Plugin.method(:const_get))
        plugins.select(&:id).each do |plugin|
          opts.on("--[no-]#{plugin.id}", plugin.description) do |v|
            options[plugin.id.to_sym] = v
          end
        end

        opts.separator ''
        opts.separator 'Global Options:'

        opts.on('--locale [LANGUAGE]', 'Change the language to output messages') do |locale|
          I18n.locale = locale
        end

        opts.on('--log-level [LEVEL]', 'Set the log verbosity') do |v|
          Stove.log_level = v
        end

        opts.on('--category [CATEGORY]', 'Set category for the cookbook') do |v|
          options[:category] = v
        end

        opts.on('--path [PATH]', 'Change the path to a cookbook') do |v|
          options[:path] = v
        end

        opts.on('--remote [REMOTE]', 'The name of the git remote to push to') do |v|
          options[:remote] = v
        end

        opts.on('--branch [BRANCH]', 'The name of the git branch to push to') do |v|
          options[:branch] = v
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts Stove::VERSION
          exit(0)
        end
      end
    end

    # The options to pass to the cookbook. Includes default values
    # that are manipulated by the option parser.
    #
    # @return [Hash]
    def options
      @options ||= Hash.new(default_value).tap do |h|
        h[:path]      = Dir.pwd
        h[:log_level] = :warn

        # Default actions/plugins
        h[:jira]      = false
        h[:start]     = true
        h[:finish]    = true

        h[:remote]    = 'origin'
        h[:branch]    = 'master'
      end
    end

    def default_value
      @default_value ||= if ENV['CLI_DEFAULT']
        !!(ENV['CLI_DEFAULT'] =~ /^(true|t|yes|y|1)$/i)
      else
        true
      end
    end
  end
end
