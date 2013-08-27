module Stove
  class Mash < ::Hash
    def method_missing(m, *args, &block)
      if has_key?(m.to_sym)
        self[m.to_sym]
      elsif has_key?(m.to_s)
        self[m.to_s]
      else
        super
      end
    end

    def methods(include_private = false)
      super + self.keys.map(&:to_sym)
    end

    def respond_to?(m, include_private = false)
      if has_key?(m.to_sym) || has_key?(m.to_s)
        true
      else
        super
      end
    end
  end
end
