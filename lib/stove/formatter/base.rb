module Stove
  module Formatter
    class Base
      class << self
        def inherited(base)
          key = base.to_s.split('::').last.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym
          formatters[key] = base
        end

        def formatter_method(*methods)
          methods.each do |name|
            formatter_methods << name

            define_method(name) do |*args|
              raise Stove::AbstractFunction
            end
          end
        end

        def formatters
          @formatters ||= {}
        end

        def formatter_methods
          @formatter_methods ||= []
        end
      end

      formatter_method :upload
    end
  end
end
