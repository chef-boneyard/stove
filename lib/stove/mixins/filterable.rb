module Stove
  module Mixin::Filterable
    def before(action, message, &block)
      Runner.filters[action][:before] << Filter.new(self, message, &block)
    end

    def after(action, message, &block)
      Runner.filters[action][:after] << Filter.new(self, message, &block)
    end
  end
end
