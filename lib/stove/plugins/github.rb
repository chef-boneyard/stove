module Stove
  class Plugin::GitHub < Plugin::Base
    id 'github'
    description 'Publish the release to GitHub'

    onload do
      require 'faraday'
      require 'faraday_middleware'
      require 'octokit'
    end

    validate(:git) do
      options[:git]
    end

    validate(:configuration) do
      Config.has_key?(:github)
    end

    validate(:access_token) do
      Config[:github].has_key?(:access_token)
    end

    after(:upload, 'Publishing the release to GitHub') do
      release = client.create_release(repository, cookbook.tag_version,
        name: cookbook.tag_version,
        body: cookbook.changeset,
      )
      asset = client.upload_asset("repos/#{repository}/releases/#{release.id}", cookbook.tarball,
        content_type: 'application/x-gzip',
        name: filename,
      )
      client.update_release_asset("repos/#{repository}/releases/assets/#{asset.id}",
        name: filename,
        label: 'Download Cookbook',
      )
    end

    def client
      return @client if @client

      config = {}.tap do |h|
        h[:middleware]   = middleware
        h[:access_token] = Config[:github][:access_token]
        h[:api_endpoint] = Config[:github][:api_endpoint] if Config[:github][:api_endpoint]
      end

      @client = Octokit::Client.new(config)
      @client
    end

    def changeset
      @changeset ||= cookbook.changeset.split("\n")[2..-1].join("\n").strip
    end

    def repository
      @repository ||= Octokit::Repository.from_url(repo_url)
    end

    def filename
      @filename ||= "#{cookbook.name}-#{cookbook.version}.tar.gz"
    end

    def middleware
      Faraday::Builder.new do |builder|
        # Handle any common errors
        builder.use Stove::Middleware::Exceptions
        builder.use Octokit::Response::RaiseError

        # Log all requests and responses (useful for development)
        builder.response :logger, log

        # Raise errors on 40x and 50x responses
        builder.response :raise_error

        # Use the default adapter (Net::HTTP)
        builder.adapter :net_http
      end
    end

    #
    # The URL for this repository on GitHub. This method automatically
    # translates SSH and git:// URLs to https:// URLs.
    #
    # @return [String]
    #
    def repo_url
      return @repo_url if @repo_url

      path = File.join('.git', 'config')
      log.debug("Calculating repo_url from `#{path}'")

      config = File.read(path)
      log.debug("Config contents:\n#{config}")

      config =~ /\[remote "#{options[:remote]}"\]\n\s+url = (.+)$/
      log.debug("Match: #{$1.inspect}")

      @repo_url = $1.to_s
                    .strip
                    .gsub(/\.git$/, '')
                    .gsub(/^\S+@(\S+):/, 'https://\1/')
                    .gsub('git://', 'https://')
      @repo_url
    end
  end
end
