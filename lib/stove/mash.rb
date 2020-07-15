module Stove
  class Mash < ::Hash
    def method_missing(m, *args, &block)
      if key?(m.to_sym)
        self[m.to_sym]
      elsif key?(m.to_s)
        self[m.to_s]
      else
        super
      end
    end

    def methods(include_private = false)
      super + keys.map(&:to_sym)
    end

    def respond_to?(m, include_private = false)
      if key?(m.to_sym) || key?(m.to_s)
        true
      else
        super
      end
    end
  end
end
