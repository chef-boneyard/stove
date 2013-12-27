Feature: Rake Task
  Background:
    * I have a cookbook named "bacon"

  Scenario: Using rake to publish a cookbook
    * I write to "Rakefile" with:
      """
      require 'stove/rake_task'
      Stove::RakeTask.new
      """
    * I successfully run `rake -T`
    * the output should contain:
      """
      rake publish[version]  # Publish this cookbook
      """
