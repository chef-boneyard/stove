Given /^the environment variable (.+) is "(.+)"$/ do |variable, value|
  set_env(variable, value)
end

Then /^the exit status will be "(.+)"$/ do |error|
  code = Stove.const_get(error).exit_code
  assert_exit_status(code)
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
