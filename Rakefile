require 'bundler/gem_tasks'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:acceptance) do |t|
  t.cucumber_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
    a.push('--strict')
    a.push('--tags ~@wip')
  end.join(' ')
end

desc 'Run all tests'
task :test => [:acceptance]

task :default => [:test]
