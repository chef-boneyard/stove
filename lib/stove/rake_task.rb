require 'rake'
require 'rake/tasklib'
require 'stove'

#
# @todo Most of these options are duplicated from the CLI, can we unify?
#
module Stove
  class RakeTask < Rake::TaskLib
    attr_accessor :stove_opts

    def initialize(name = nil)
      yield self if block_given?

      desc 'Publish this cookbook' unless ::Rake.application.last_comment
      task(name || :publish) do |t, args|
        Cli.new(stove_opts || []).execute!
      end
    end

    def log_level=(level)
      Stove.log_level = level
    end
  end
end
