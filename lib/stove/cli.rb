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

      # Login command
      if @argv.first == 'login'
        if options[:username].nil? || options[:username].to_s.strip.empty?
          raise "Missing argument `--username'!"
        end

        if options[:key].nil? || options[:key].to_s.strip.empty?
          raise "Missing argument `--key'!"
        end

        Config.username = options[:username]
        Config.key      = options[:key]
        Config.endpoint = options[:endpoint] unless options[:endpoint].nil?
        Config.save

        @stdout.puts "Successfully saved config to `#{Config.__path__}'!"
        @kernel.exit(0)
        return
      end

      # Override configs
      Config.endpoint        = options[:endpoint]        if options[:endpoint]
      Config.username        = options[:username]        if options[:username]
      Config.key             = options[:key]             if options[:key]
      Config.artifactory     = options[:artifactory]     if options[:artifactory]
      Config.artifactory_key = options[:artifactory_key] if options[:artifactory_key]
      Config.ssl_verify      = options[:ssl_verify]

      # Set the log level
      Stove.log_level = options[:log_level]

      # Useful debugging output for when people type the wrong fucking command
      # and then open an issue like it's somehow my fault
      log.info("Options: #{options.inspect}")
      log.info("ARGV: #{@argv.inspect}")

      # Yank command
      if @argv.first == 'yank'
        name = @argv[1] || Cookbook.new(options[:path]).name

        if Supermarket.yank(name)
          @stdout.puts "Successfully yanked #{name}!"
          @kernel.exit(0)
        else
          @stderr.puts "I could not find a cookbook named #{name}!"
          @kernel.exit(1)
        end

        return
      end

      # Make a new cookbook object - this will raise an exception if there is
      # no cookbook at the given path
      cookbook = Cookbook.new(options[:path])

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

        opts.on('--no-git', 'Do not use the git plugin. Skips tagging if specified.') do
          options[:no_git] = true
        end

        opts.separator ''
        opts.separator 'Upload Options:'

        opts.on('--endpoint [URL]', 'Supermarket endpoint') do |v|
          options[:endpoint] = v
        end

        opts.on('--username [USERNAME]', 'Username to authenticate with') do |v|
          options[:username] = v
        end

        opts.on('--key [PATH]', 'Path to the private key on disk') do |v|
          options[:key] = v
        end

        opts.on('--[no-]extended-metadata', 'Include non-backwards compatible metadata keys such as `issues_url`') do |v|
          options[:extended_metadata] = v
        end

        opts.on('--no-ssl-verify', 'Turn off ssl verify') do
          options[:ssl_verify] = false
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
        opts.separator 'Artifactory Options:'

        opts.on('--artifactory [URL]', 'URL for the Artifactory repository') do |v|
          options[:artifactory] = v
        end

        opts.on('--artifactory-key [KEY]', 'Artifactory API key to use') do |v|
          options[:artifactory_key] = if v[0] == '@'
            # If passed a key looking like @foo, read it as a file. This allows
            # passing in the key securely.
            IO.read(File.expand_path(v[1..-1]))
          else
            v
          end
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
        :endpoint          => nil,
        :username          => Config.username,
        :key               => Config.key,
        :extended_metadata => true,
        :ssl_verify        => true,

        # Git options
        :remote => 'origin',
        :branch => 'master',
        :sign   => false,

        # Artifactory options
        :artifactory     => false,
        :artifactory_key => ENV['ARTIFACTORY_API_KEY'],

        # Global options
        :log_level => :warn,
        :path      => Dir.pwd,
      }
    end
  end
end
