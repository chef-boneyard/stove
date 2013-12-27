module Stove
  module Error
    class StoveError < StandardError
      def initialize(options = {})
        return super(options[:_message]) if options[:_message]

        class_name = self.class.to_s.split('::').last
        error_key  = Util.underscore(class_name)

        super I18n.t("stove.errors.#{error_key}", options)
      end
    end

    class ValidationFailed < StoveError
      def initialize(klass, id, options = {})
        super _message: I18n.t("stove.validations.#{klass}.#{id}", options)
      end
    end

    class GitFailed < StoveError; end
    class MetadataNotFound < StoveError; end
    class ServerUnavailable < StoveError; end
  end
end
