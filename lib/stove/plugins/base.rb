module Stove
  class Plugin::Base
    include Logify

    extend Mixin::Optionable
    extend Mixin::Validatable

    class << self
      def run(description, &block)
        actions << Proc.new do |instance|
          log.info { description }
          instance.instance_eval(&block)
        end
      end

      def actions
        @actions ||= []
      end
    end

    option :id
    option :description

    attr_reader :cookbook
    attr_reader :options

    def initialize(cookbook, options = {})
      @cookbook, @options = cookbook, options
    end

    def run
      run_validations
      run_actions
    end

    def run_validations
      self.class.validations.each do |id, validation|
        validation.run(cookbook, options)
      end
    end

    def run_actions
      self.class.actions.each do |action|
        action.call(self)
      end
    end
  end
end
