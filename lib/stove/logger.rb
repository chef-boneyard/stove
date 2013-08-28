require 'logger'

module Stove
  module Logger
    class << self
      def set_level(level)
        logger.level = level_to_constant(level)
        logger
      end

      def set_output(output)
        old_level = @logger.sev_threshold

        @logger = ::Logger.new(output)
        @logger.level = old_level
        @logger
      end

      [:fatal, :error, :warn, :info, :debug, :sev_threshold].each do |name|
        define_method(name) do |*args|
          logger.send(name, *args)
        end
      end

      private
        def logger
          @logger ||= begin
            logger = ::Logger.new($stdout)
            logger.level = ::Logger::WARN
            logger
          end
        end

        # Convert a string to it's logger constant.
        #
        # @return [Object]
        def level_to_constant(level)
          return level if level.kind_of?(Fixnum)
          case level.to_s.strip.downcase.to_sym
            when :fatal
              ::Logger::FATAL
            when :error
              ::Logger::ERROR
            when :warn
              ::Logger::WARN
            when :info
              ::Logger::INFO
            when :debug
              ::Logger::DEBUG
            else
              ::Logger::INFO
            end
        end
    end
  end
end
