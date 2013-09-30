require 'fileutils'
require 'time'

module Stove
  class Cookbook
    require_relative 'cookbook/metadata'

    include Stove::Git

    # The path to this cookbook.
    #
    # @return [String]
    attr_reader :path

    # The name of the cookbook (must correspond to the name of the
    # cookbook on the community site).
    #
    # @return [String]
    attr_reader :name

    # The version of this cookbook (originally).
    #
    # @return [String]
    attr_reader :version

    # The new version of the cookbook.
    #
    # @return [String]
    attr_reader :new_version

    # The metadata for this cookbook.
    #
    # @return [Stove::Cookbook::Metadata]
    attr_reader :metadata

    # The list of options passed to the cookbook.
    #
    # @return [Hash]
    attr_reader :options

    # Create a new wrapper around the cookbook object.
    #
    # @param [Hash] options
    #   the list of options
    def initialize(options = {})
      @path = options[:path] || Dir.pwd
      @new_version = options[:new_version]
      @options = options

      load_metadata!
    end

    # The category for this cookbook on the community site.
    #
    # @return [String]
    def category
      @category ||= options[:category] || Stove::CommunitySite.cookbook(name)['category']
    rescue
      raise Stove::CookbookCategoryNotFound
    end

    # The URL for the cookbook on the Community Site.
    #
    # @return [String]
    def url
      "#{Stove::CommunitySite.http_uri}/cookbooks/#{name}"
    end

    # Deterine if this cookbook version is released on the community site
    def released?
      @_released ||= begin
        Stove::CommunitySite.cookbook(name, version)
        true
      rescue Stove::BadResponse
        false
      end
    end

    # The unreleased JIRA tickets for this cookbook.
    #
    # @return [Hashie::Dash, Array]
    def unreleased_tickets
      @unreleased_tickets ||= Stove::JIRA.unreleased_tickets_for(name)
    end

    #
    def release!
      if options[:git]
        validate_git_repo!
        validate_git_clean!
        validate_remote_updated!
      end

      version_bump

      if options[:changelog]
        update_changelog
      end

      if options[:git]
        Dir.chdir(path) do
          git "add metadata.rb"
          git "add CHANGELOG.md"
          git "commit -m 'Version bump to v#{version}'"
          git "push #{options[:remote] || 'origin'} #{options[:branch] || 'master'}"

          git "tag v#{version}"
          git "push #{options[:remote] || 'origin'} v#{version}"
        end
      end

      if options[:upload]
        upload
      end

      if options[:jira]
        resolve_jira_issues
      end
    end

    #
    def upload
      return true unless options[:upload]
      Stove::Uploader.new(self).upload!
    end

    private
      # Load the metadata and set the @metadata instance variable.
      #
      # @raise [ArgumentError]
      #   if there is no metadata.rb
      #
      # @return [String]
      #   the path to the metadata file
      def load_metadata!
        metadata_path = File.expand_path(File.join(path, 'metadata.rb'))

        @metadata = Stove::Cookbook::Metadata.from_file(metadata_path)
        @name     = @metadata.name
        @version  = @metadata.version

        metadata_path
      end
      alias_method :reload_metadata!, :load_metadata!

      # Create a new CHANGELOG in markdown format.
      #
      # @example given a cookbook named bacon
      #   cookbook.create_changelog #=> <<EOH
      # bacon Cookbook CHANGELOG
      # ------------------------
      # EOH
      #
      # @return [String]
      #   the path to the new CHANGELOG
      def create_changelog
        destination = File.join(path, 'CHANGELOG.md')

        # Be idempotent :)
        return destination if File.exists?(destination)

        header  = "#{name} Cookbook CHANGELOG\n"
        header << "#{'='*header.length}\n"
        header << "This file is used to list changes made in each version of the #{cookbook.name} cookbook.\n\n"

        File.open(destination, 'wb') do |file|
          file.write(header)
        end

        destination
      end

      # Update the CHANGELOG with the new contents, but inserting
      # the newest version's CHANGELOG at the top of the file (after
      # the header)
      def update_changelog
        changelog = create_changelog
        contents  = File.readlines(changelog)

        index = contents.find_index { |line| line =~ /(--)+/ } - 2
        contents.insert(index, "\n" + generate_changelog)

        Dir.mktmpdir do |dir|
          tmpfile = File.join(dir, 'CHANGELOG.md')
          File.open(tmpfile, 'w') { |f| f.write(contents.join('')) }
          response = shellout("$EDITOR #{tmpfile}")

          unless response.success?
            Stove::Logger.debug response.stderr
            raise Stove::Error, response.stderr
          end

          FileUtils.mv(tmpfile, File.join(path, 'CHANGELOG.md'))
        end
      rescue SystemExit, Interrupt
        raise Stove::UserCanceledError
      end

      # Generate a CHANGELOG in markdown format.
      #
      # @param [String] version
      #   the version string in x.y.z format
      #
      # @return [String]
      def generate_changelog
        contents = []
        contents << "v#{version}"
        contents << '-'*(version.length+1)

        if options[:jira]
          by_type = unreleased_tickets.inject({}) do |hash, ticket|
            issue_type = ticket.fields.current['issuetype']['name']
            hash[issue_type] ||= []
            hash[issue_type] << {
              number:  ticket.jira_key,
              details: ticket.fields.current['summary'],
            }

            hash
          end

          by_type.each do |issue_type, tickets|
            contents << "### #{issue_type}"
            tickets.sort { |a,b| b[:number].to_i <=> a[:number].to_i }.each do |ticket|
              contents << "- **[#{ticket[:number]}](#{Stove::JIRA::JIRA_URL}/browse/#{ticket[:number]})** - #{ticket[:details]}"
            end
            contents << ""
          end
        else
          contents << "_Enter CHANGELOG for #{name} (#{version}) here_"
          contents << ""
        end

        contents.join("\n")
      end

      # Bump the version in the metdata.rb to the specified
      # parameter.
      #
      # @return [String]
      #   the new version string
      def version_bump
        return true if new_version.to_s == version.to_s

        metadata_path = File.join(path, 'metadata.rb')
        contents      = File.read(metadata_path)

        contents.sub!(/^version(\s+)('|")#{version.to_s}('|")/, "version\\1\\2#{new_version.to_s}\\3")

        File.open(metadata_path, 'w') { |f| f.write(contents) }
        reload_metadata!
      end

      # Resolve all the JIRA issues that have been merged.
      def resolve_jira_issues
        unreleased_tickets.collect do |ticket|
          Thread.new { Stove::JIRA.comment_and_close(ticket, self) }
        end.map(&:join)
      end

      # Validate that the current working directory is git repo.
      #
      # @raise [Stove::GitError::NotARepo]
      #   if this is not currently a git repo
      def validate_git_repo!
        Dir.chdir(path) do
          raise Stove::GitError::NotARepo unless git_repo?
        end
      end

      # Validate that the current.
      #
      # @raise [Stove::GitError::DirtyRepo]
      #   if the current working directory is not clean
      def validate_git_clean!
        Dir.chdir(path) do
          raise Stove::GitError::DirtyRepo unless git_repo_clean?
        end
      end

      # Validate that the remote git repository is up to date.
      #
      # @raise [Stove::GitError::OutOfSync]
      #   if the current git repo is not up to date with the remote
      def validate_remote_updated!
        Dir.chdir(path) do
          raise Stove::GitError::OutOfSync unless git_remote_uptodate?(options)
        end
      end
  end
end
