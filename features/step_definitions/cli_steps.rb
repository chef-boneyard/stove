Given /^the environment variable (.+) is "(.+)"$/ do |variable, value|
  set_env(variable, value)
end

Then /^the exit status will be "(.+)"$/ do |error|
  # Ruby 1.9.3 sucks
  klass = error.split('::').inject(Stove) { |c, n| c.const_get(n) }
  assert_exit_status(klass.exit_code)
end

When /^the CLI options are all off$/ do
  class Stove::Cli
    private
      def options
        @options ||= {
          :git       => false,
          :jira      => false,
          :upload    => false,
          :changelog => false,
          :log_level => :debug,
        }
      end
  end
end
