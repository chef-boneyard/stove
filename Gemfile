source "https://rubygems.org"
gemspec name: "stove"

# testing compatibility
gem "rack", "< 2"

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5")
  gem "activesupport", "~> 5.0"
end