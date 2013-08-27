require 'logger'

module Stove
  module Logger
    class << self
      def set_level(level)
        logger.level = level
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
    end
  end
end
