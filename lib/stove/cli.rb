require 'optparse'
require 'stove'

module Stove
  class Cli
    include Logify

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      $stdout, $stderr = @stdout, @stderr

      # Parse the options hash
      option_parser.parse!(@argv)

      # Stupid special use cases
      if @argv.first == 'login'
        if options[:username].nil? || options[:username].to_s.strip.empty?
          raise "Missing argument `--username'!"
        end

        if options[:key].nil? || options[:key].to_s.strip.empty?
          raise "Missing argument `--key'!"
        end

        Config.username = options[:username]
        Config.key      = options[:key]
        Config.save

        @stdout.puts "Successfully saved config to `#{Config.__path__}'!"
        return
      end

      # Override configs
      Config.endpoint = options[:endpoint] if options[:endpoint]
      Config.username = options[:username] if options[:username]
      Config.key      = options[:key]      if options[:key]

      # Set the log level
      Stove.log_level = options[:log_level]

      # Parse out the version from ARGV
      options[:version] = @argv.shift

      # Useful debugging output for when people type the wrong fucking command
      # and then open an issue like it's somehow my fault
      log.info("Options: #{options.inspect}")
      log.info("ARGV: #{@argv.inspect}")

      # Make a new cookbook object - this will raise an exception if there is
      # no cookbook at the given path
      cookbook = Cookbook.new(options[:path])

      # Set the category on the cookbook object if one was given
      if category = options.delete(:category)
        cookbook.category = category
      end

      # Now execute the actual runners (validations and errors might occur)
      runner = Runner.new(cookbook, options)
      runner.run

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
        opts.banner = 'Usage: stove [OPTIONS]'

        opts.separator ''
        opts.separator 'Plugins:'

        opts.on('--no-git', 'Do not use the git plugin') do
          options[:no_git] = true
        end

        opts.separator ''
        opts.separator 'Upload Options:'

        opts.on('--endpoint [URL]', 'Upload URL endpoint') do |v|
          options[:endpoint] = v
        end

        opts.on('--username [USERNAME]', 'Username to authenticate with') do |v|
          options[:username] = v
        end

        opts.on('--key [PATH]', 'Path to the private key on disk') do |v|
          options[:key] = v
        end

        opts.on('--category [CATEGORY]', 'Category for the cookbook') do |v|
          options[:category] = v
        end

        opts.separator ''
        opts.separator 'Git Options:'

        opts.on('--remote [REMOTE]', 'Name of the git remote') do |v|
          options[:remote] = v
        end

        opts.on('--branch [BRANCH]', 'Name of the git branch') do |v|
          options[:branch] = v
        end

        opts.on('--sign', 'Sign git tags') do
          options[:sign] = true
        end

        opts.separator ''
        opts.separator 'Global Options:'

        opts.on('--log-level [LEVEL]', 'Set the log verbosity') do |v|
          options[:log_level] = v
        end

        opts.on('--path [PATH]', 'Change the path to a cookbook') do |v|
          options[:path] = v
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
      @options ||= {
        # Upload options
        :endpoint => nil,
        :username => Config.username,
        :key      => Config.key,
        :category => nil,

        # Git options
        :remote => 'origin',
        :branch => 'master',
        :sign   => false,

        # Global options
        :log_level => :warn,
        :path      => Dir.pwd,
      }
    end
  end
end
