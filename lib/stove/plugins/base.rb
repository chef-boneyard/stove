module Stove
  class Plugin::Base
    extend Mixin::Filterable
    extend Mixin::Loggable
    extend Mixin::Optionable
    extend Mixin::Validatable

    option :id
    option :description

    class << self
      def onload(&block)
        if block
          @onload = block
        else
          @onload
        end
      end
    end

    attr_reader :cookbook
    attr_reader :options

    def initialize(cookbook, options = {})
      @cookbook, @options = cookbook, options
      instance_eval(&onload)
    end

    private

    def onload
      self.class.onload || Proc.new {}
    end
  end
end
