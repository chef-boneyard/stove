module Stove
  class Runner
    include Logify

    attr_reader :cookbook
    attr_reader :options

    def initialize(cookbook, options = {})
      @cookbook = cookbook
      @options  = options
    end

    def run
      run_plugin :git
      if Config.artifactory
        run_plugin :artifactory
      else
        run_plugin :supermarket
      end
    end

    private

    def run_plugin(name)
      if skip?(name)
        log.info { "Skipping plugin `:#{name}'" }
      else
        log.info { "Running plugin `:#{name}'" }
        klass = Plugin.const_get(Util.camelize(name))
        klass.new(cookbook, options).run
      end
    end

    def skip?(thing)
      key = "no_#{thing}".to_sym
      !!options[key]
    end
  end
end
