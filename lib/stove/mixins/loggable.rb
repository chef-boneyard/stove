require 'log4r'

module Stove
  module Mixin::Loggable
    def self.extended(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def log
        return @log if @log

        @log = Log4r::Logger.new(self.name)
        @log.outputters = Log4r::Outputter.stdout
        @log.level = 1
        @log
      end
    end

    module InstanceMethods
      def log
        self.class.log
      end
    end
  end
end
