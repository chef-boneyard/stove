module Stove
  module Formatter
    # Silence all output
    class Silent < Base
      Stove::Formatter::Base.formatter_methods.each do |name|
        define_method(name) do |*args|; end
      end
    end
  end
end
