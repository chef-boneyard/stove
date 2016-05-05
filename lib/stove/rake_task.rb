require 'rake'
require 'rake/tasklib'
require 'stove'

module Stove
  class RakeTask < Rake::TaskLib
    attr_accessor :stove_opts

    def initialize(name = nil)
      yield self if block_given?

      desc 'Publish this cookbook' unless ::Rake.application.last_description
      task(name || :publish) do |t, args|
        Cli.new(stove_opts || []).execute!
      end
    end

    def log_level=(level)
      Stove.log_level = level
    end
  end
end
