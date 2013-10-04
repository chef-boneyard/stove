module Stove
  class Error < StandardError
    class << self
      def set_exit_code(code)
        define_method(:exit_code) { code }
        define_singleton_method(:exit_code) { code }
      end
    end

    set_exit_code 100
  end

  class InvalidVersionError < Error
    set_exit_code 101

    def message
      'You must specify a valid version!'
    end
  end

  class MetadataNotFound < Error
    set_exit_code 102

    def initialize(filepath)
      @filepath = File.expand_path(filepath) rescue filepath
    end

    def message
      "No metadata.rb found at: '#{@filepath}'"
    end
  end

  class CookbookCategoryNotFound < Error
    set_exit_code 110

    def message
      'The cookbook\'s category could not be inferred from the community site. ' <<
      'If this is a new cookbook, you must specify the category with the ' <<
      '--category flag.'
    end
  end

  class UserCanceledError < Error
    set_exit_code 120

    def message
      'Action canceled by user!'
    end
  end

  class GitError < Error
    set_exit_code 130

    def message
      'Git Error: ' + super
    end

    class NotARepo < GitError
      set_exit_code 131

      def message
        'Not a git repo!'
      end
    end

    class DirtyRepo < GitError
      set_exit_code 132

      def message
        'You have untracked files!'
      end
    end

    class OutOfSync < GitError
      set_exit_code 133

      def message
        'Your remote repository is out of sync!'
      end
    end
  end

  class UploadError < Error
    set_exit_code 140

    def initialize(response)
      @response = response
    end

    def message
      "The following errors occured when uploading:\n" <<
        (@response.parsed_response['error_messages'] || []).map do |error|
          "  - #{error}"
        end.join("\n")
    end
  end

  class BadResponse < Error
    set_exit_code 150

    def initialize(response)
      @response = response
    end

    def message
      "The following errors occured when making the request:\n" <<
        @response.parsed_response
    end
  end

  class AbstractFunction < Error
    set_exit_code 160
  end

  class InvalidChangelogFormat < Error
    set_exit_code 170
  end
end
