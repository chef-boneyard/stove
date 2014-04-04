module Stove
  class Runner
    include Mixin::Instanceable
    include Logify
    include Mixin::Optionable

    class << self
      def action(id)
        actions << id
        filters[id] = { before: [], after: [] }
      end
    end

    attr_reader :cookbook
    attr_reader :options
    attr_reader :validations

    option :actions, []
    option :filters, {}

    action :start
    action :bump
    action :changelog
    action :upload
    action :dev
    action :finish

    def initialize
      @validations = []
    end

    def run(cookbook, options = {})
      @cookbook, @options = cookbook, options

      run_validations
      run_actions
    end

    private

    def skip?(thing)
      !options[thing.to_sym]
    end

    def run_actions
      actions.each do |action|
        if skip?(action)
          log.debug("Skipping action `#{action}' and filters")
        else
          run_filters(:before, action)

          klass = Action.const_get(Util.camelize(action))
          klass.new(cookbook, options).run

          run_filters(:after, action)
        end
      end
    end

    def run_filters(placement, action)
      filters[action][placement].each do |filter|
        plugin = filter.klass.id

        if skip?(plugin)
          log.debug("Skipping filter `#{filter.message}'")
        else
          filter.run(cookbook, options)
        end
      end
    end

    def run_validations
      validations.each do |validation|
        parent = validation.klass.id

        if skip?(parent)
          log.debug("Skipping validation `#{validation.id}' for `#{parent}'")
        else
          validation.run(cookbook, options)
        end
      end
    end
  end
end
