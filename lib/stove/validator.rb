module Stove
  class Validator
    include Logify

    include Mixin::Insideable

    #
    # The class that created this validator.
    #
    # @return [~Class]
    #
    attr_reader :klass

    #
    # The identifier or field this validator runs against.
    #
    # @return [Symbol]
    #
    attr_reader :id

    #
    # The block to execute to see if the validation passes.
    #
    # @return [Proc]
    #
    attr_reader :block

    #
    # Create a new validator object.
    #
    # @param [~Class] klass
    #   the class that created this validator
    # @param [Symbol] id
    #   the identifier or field this validator runs against
    # @param [Proc] block
    #   the block to execute to see if the validation passes
    #
    def initialize(klass, id, &block)
      @klass   = klass
      @id      = id
      @block   = block
    end

    #
    # Execute this validation in the context of the creating class, inside the
    # given cookbook's path.
    #
    # @param [Cookbook]
    #   the cookbook to run this validation against
    #
    def run(cookbook, options = {})
      log.info("Running validations for `#{klass.id}.#{id}'")

      inside(cookbook) do
        instance = klass.new(cookbook, options)
        unless result = instance.instance_eval(&block)
          log.debug("Validation failed, result: #{result.inspect}")

          # Convert the class and id to their magical equivalents
          error = Error.const_get("#{Util.camelize(klass.id)}#{Util.camelize(id)}ValidationFailed")
          raise error.new(path: Dir.pwd, result: result)
        end
      end

      log.debug("Validation #{id} passed!")
    end
  end
end
