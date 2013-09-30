require 'octokit'

module Stove
  class GitHub
    attr_reader :cookbook

    def initialize(cookbook)
      @cookbook = cookbook

      Octokit.configure do |config|
        config.access_token = Stove::Config['github_access_token']
      end
    end

    def publish_release!
      release = Octokit.create_release(repository, cookbook.tag_version,
        name: cookbook.tag_version,
        body: changeset,
      )
      asset = Octokit.upload_asset("repos/#{repository}/releases/#{release.id}", cookbook.tarball,
        content_type: 'application/x-gzip',
        name: filename,
      )
      Octokit.update_release_asset("repos/#{repository}/releases/assets/#{asset.id}",
        name: filename,
        label: 'Download Cookbook',
      )
    end

    private
      def repository
        @repository ||= Octokit::Repository.from_url(cookbook.repository_url)
      end

      def changeset
        cookbook.changeset.split("\n")[2..-1].join("\n").strip
      end

      def filename
        @filename ||= "#{cookbook.name}-#{cookbook.version}.tar.gz"
      end
  end
end
