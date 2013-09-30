require 'rake'
require 'rake/tasklib'

module Stove
  #
  # Run Stove tasks from your +Rakefile+.
  #
  # @example
  #   desc "Run stove tasks"
  #   Stove::RakeTask.new(:release) do |stove|
  #     stove.git = true
  #     stove.devodd = true
  #   end
  #
  class RakeTask < ::Rake::TaskLib
    class << self
      #
      # Define a CLI option.
      #
      # @param [Symbol] option
      #
      def cli_option(option)
        define_method("#{option}=".to_sym) do |value|
          options[option] = value
        end

        define_method(option.to_sym) do
          options[option]
        end
      end
    end

    # @return [Symbol]
    attr_accessor :name

    # @return [Hash]
    attr_reader :options

    def initialize(task_name = nil)
      @options = {}
      @name    = (task_name || :publish).to_sym

      yield self if block_given?

      desc 'Publish this cookbook' unless ::Rake.application.last_comment
      task name do |t, args|
        require 'stove'
        Stove::Cookbook.new(options).release!
      end
    end

    cli_option :branch
    cli_option :category
    cli_option :changelog
    cli_option :devodd
    cli_option :git
    cli_option :jira
    cli_option :log_level
    cli_option :path
    cli_option :remote
    cli_option :upload
  end
end
