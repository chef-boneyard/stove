module Stove
  class Action::Base
    extend Mixin::Loggable
    extend Mixin::Optionable
    extend Mixin::Validatable

    option :id
    option :description

    attr_reader :cookbook
    attr_reader :options

    def initialize(cookbook, options = {})
      @cookbook, @options = cookbook, options
    end

    def run
      raise Error::AbstractMethod.new(method: 'Action::Base#run')
    end
  end
end
