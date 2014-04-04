require 'rake'
require 'rake/tasklib'
require 'stove'

#
# @todo Most of these options are duplicated from the CLI, can we unify?
#
module Stove
  class RakeTask < Rake::TaskLib
    include Logify

    class << self
      #
      # Define a CLI option.
      #
      # @param [Symbol] option
      #
      def option(option)
        define_method("#{option}=".to_sym) do |value|
          log.debug("Setting #{option} = #{value.inspect}")
          options[option.to_sym] = value
        end
      end
    end

    # Actions
    Action.constants.map(&Action.method(:const_get)).select(&:id).each do |action|
      option action.id
    end

    # Plugins
    Plugin.constants.map(&Plugin.method(:const_get)).select(&:id).each do |plugin|
      option plugin.id
    end

    option :category
    option :path
    option :remote
    option :branch

    def initialize(name = nil)
      yield self if block_given?

      desc 'Publish this cookbook' unless ::Rake.application.last_comment
      task(name || :publish, :version) do |t, args|
        log.info("Options: #{options.inspect}")

        cookbook = Cookbook.new(options[:path])
        options[:version] = args[:version] || minor_bump(cookbook.version)
        Runner.run(cookbook, options)
      end
    end

    def locale=(locale)
      log.debug("Setting locale = #{locale.inspect}")
      I18n.locale = locale
    end

    def log_level=(level)
      log.debug("Setting log_level = #{level.inspect}")
      Stove.log_level = level
    end

    private

    def minor_bump(version)
      split = version.split('.').map(&:to_i)
      split[2] += 1
      split.join('.')
    end

    def options
      @options ||= Hash.new(true).tap do |h|
        h[:path] = Dir.pwd
        h[:jira] = false

        h[:remote]    = 'origin'
        h[:branch]    = 'master'
      end
    end
  end
end
