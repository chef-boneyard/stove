require 'singleton'

module Stove
  module Mixin::Instanceable
    def self.included(base)
      base.send(:include, Singleton)
      base.send(:extend, ClassMethods)
    end

    def self.extended(base)
      base.send(:include, Singleton)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def to_s; instance.to_s; end
      def inspect; instance.inspect; end

      def method_missing(m, *args, &block)
        instance.send(m, *args, &block)
      end
    end
  end
end
