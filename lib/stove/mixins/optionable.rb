module Stove
  module Mixin::Optionable
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    def self.extended(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      #
      # This is a magical method. It does three things:
      #
      # 1. Defines a class method getter and setter for the given option
      # 2. Defines an instance method that delegates to the class method
      # 3. (Optionally) sets the initial value
      #
      # @param [String, Symbol] name
      #   the name of the option
      # @param [Object] initial
      #   the initial value to set (optional)
      #
      def option(name, initial = UNSET_VALUE)
        define_singleton_method(name) do |value = UNSET_VALUE|
          if value == UNSET_VALUE
            instance_variable_get("@#{name}")
          else
            instance_variable_set("@#{name}", value)
          end
        end

        define_method(name) { self.class.send(name) }

        unless initial == UNSET_VALUE
          send(name, initial)
        end
      end
    end
  end
end
