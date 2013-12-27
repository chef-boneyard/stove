module Stove
  module Mixin::Insideable
    #
    # Execute the command inside the cookbook.
    #
    # @param [Cookbook]
    #   the cookbook to execute inside of
    #
    def inside(cookbook, &block)
      Dir.chdir(cookbook.path, &block)
    end
  end
end
