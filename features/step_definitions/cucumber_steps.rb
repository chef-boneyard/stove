# These are steps that should really exist in cucumber, but they don't...
When /^the environment variable "(.+)" is "(.+)"/ do |variable, value|
  set_env(variable, value)
end

When /^the environment variable "(.+)" is unset$/ do |variable|
  set_env(variable, nil)
end

Then /^it should (pass|fail) with "(.+)"$/ do |pass_fail, partial|
  self.__send__("assert_#{pass_fail}ing_with", partial)
end
