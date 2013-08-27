module Stove
  module Formatter
    class Human < Base
      def upload(cookbook)
        puts "Uploaded #{cookbook.name} (#{cookbook.version}) to '#{cookbook.url}'"
      end
    end
  end
end
