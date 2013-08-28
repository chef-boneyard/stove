module Stove
  class Config < ::Hash
    class << self
      def [](thing)
        instance[thing]
      end

      def instance
        @instance ||= load!
      end

      private
        def load!
          JSON.parse(File.read(File.expand_path('~/.stove'))) rescue {}
        end
    end
  end
end
