module Stove
  class Filter
    include Logify

    include Mixin::Insideable

    #
    # The class that created this filter.
    #
    # @return [~Plugin::Base]
    #
    attr_reader :klass

    #
    # The message given by the filter.
    #
    # @return [String]
    #
    attr_reader :message

    #
    # The block captured by the filter.
    #
    # @return [Proc]
    #
    attr_reader :block

    #
    # Create a new filter object.
    #
    # @param [~Plugin::Base] klass
    #   the class that created this filter
    # @param [String] message
    #   the message given by the filter
    # @param [Proc] block
    #   the block captured by this filter
    #
    def initialize(klass, message, &block)
      @klass   = klass
      @message = message
      @block   = block
    end

    #
    # Execute this filter in the context of the creating class, inside the
    # given cookbook's path.
    #
    # @param [Cookbook]
    #   the cookbook to run this filter against
    #
    def run(cookbook, options = {})
      log.info(message)
      instance = klass.new(cookbook, options)

      inside(cookbook) do
        instance.instance_eval(&block)
      end
    end
  end
end
