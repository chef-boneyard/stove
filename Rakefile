require "bundler"
require "bundler/gem_helper"

Bundler::GemHelper.install_tasks name: "stove"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = [].tap do |a|
    a.push("--color")
    a.push("--format progress")
  end.join(" ")
end

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:acceptance) do |t|
  t.cucumber_opts = [].tap do |a|
    a.push("--color")
    a.push("--format progress")
    a.push("--strict")
    a.push('--tags "not @wip"')
  end.join(" ")
end

desc "Run all tests"
task test: %i{unit acceptance}

task default: [:test]
