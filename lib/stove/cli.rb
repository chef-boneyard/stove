require 'optparse'
require 'stove'

module Stove
  class Cli
    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      $stdout, @stderr = @stdout, @stderr
    end

    def execute!
      option_parser.parse!(@argv)
      options[:new_version] = @argv.first

      raise Stove::InvalidVersionError unless valid_version?(options[:new_version])

      Stove::Logger.set_level(options.delete(:log_level))

      Stove::Cookbook.new(options).release!
      @kernel.exit(0)
    rescue => e
      @stderr.puts "#{e.class}: #{e.message}"

      if Stove::Logger.sev_threshold == ::Logger::DEBUG
        @stderr.puts "  #{e.backtrace.join("\n  ")}"
      end

      @kernel.exit(e.respond_to?(:exit_code) ? e.exit_code : 500)
    ensure
      $stdout, $stderr = STDOUT, STDERR
    end

    private
      # The option parser for handling command line flags.
      #
      # @return [OptionParser]
      def option_parser
        @option_parser ||= OptionParser.new do |opts|
          opts.banner = "Usage: bake x.y.z"

          opts.on('-l', '--log-level [LEVEL]', [:fatal, :error, :warn, :info, :debug], 'Ruby log level') do |v|
            options[:log_level] = v
          end

          opts.on('-c', '--category [CATEGORY]', String, 'The category for the cookbook (optional for existing cookbooks)') do |v|
            options[:category] = v
          end

          opts.on('-p', '--path [PATH]', String, 'The path to the cookbook to release (default: PWD)') do |v|
            options[:path] = v
          end

          opts.on('--[no-]git', 'Automatically tag and push to git (default: true)') do |v|
            options[:git] = v
          end

          opts.on('-r', '--remote', String, 'The name of the git remote to push to') do |v|
            options[:remote] = v
          end

          opts.on('-b', '--branch', String, 'The name of the git branch to push to') do |v|
            options[:branch] = v
          end

          opts.on('--[no-]jira', 'Automatically populate the CHANGELOG from JIRA tickets and close them (default: false)') do |v|
            options[:jira] = v
          end

          opts.on('--[no-]upload', 'Upload the cookbook to the Opscode Community Site (default: true)') do |v|
            options[:upload] = v
          end

          opts.on('--[no-]changelog', 'Automatically generate a CHANGELOG (default: true)') do |v|
            options[:changelog] = v
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
          :path      => Dir.pwd,
          :git       => true,
          :remote    => 'origin',
          :branch    => 'master',
          :jira      => false,
          :upload    => true,
          :changelog => true,
          :log_level => :warn,
        }
      end

      # Determine if the given string is a valid version string.
      #
      # @return [Boolean]
      def valid_version?(version)
        version.to_s =~ /^\d+\.\d+\.\d+$/
      end
  end
end
