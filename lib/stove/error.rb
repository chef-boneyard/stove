require 'erb'

module Stove
  module Error
    class ErrorBinding
      def initialize(options = {})
        options.each do |key, value|
          instance_variable_set(:"@#{key}", value)
        end
      end

      def get_binding
        binding
      end
    end

    class StoveError < StandardError
      def initialize(options = {})
        @options  = options
        @filename = options.delete(:_template)

        super()
      end

      def message
        erb = ERB.new(File.read(template))
        erb.result(ErrorBinding.new(@options).get_binding)
      end
      alias_method :to_s, :message

      private

      def template
        class_name = self.class.to_s.split('::').last
        filename   = @filename || Util.underscore(class_name)
        Stove.root.join('templates', 'errors', "#{filename}.erb")
      end
    end

    class GitFailed < StoveError; end
    class GitTaggingFailed < StoveError; end
    class MetadataNotFound < StoveError; end
    class ServerUnavailable < StoveError; end
    class CookbookAlreadyExists < StoveError; end

    # Validations
    class ValidationFailed < StoveError; end
    class SupermarketCategoryValidationFailed < ValidationFailed; end
    class SupermarketKeyValidationFailed < ValidationFailed; end
    class SupermarketUsernameValidationFailed < ValidationFailed; end
    class GitCleanValidationFailed < ValidationFailed; end
    class GitRepositoryValidationFailed < ValidationFailed; end
    class GitUpToDateValidationFailed < ValidationFailed; end
    class ArtifactoryKeyValidationFailed < ValidationFailed; end
  end
end
