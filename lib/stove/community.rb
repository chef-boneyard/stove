require 'faraday'
require 'faraday_middleware'

module Stove
  class Community
    include Mixin::Instanceable
    include Mixin::Loggable
    include Mixin::Optionable

    option :base_url,
      ENV['COMMUNITY_URL'] || 'https://cookbooks.opscode.com/api/v1'

    #
    # Get and cache a community cookbook's JSON response from the given name
    # and version.
    #
    # @example Find a cookbook by name
    #   Community.cookbook('apache2') #=> {...}
    #
    # @example Find a cookbook by name and version
    #   Community.cookbook('apache2', '1.0.0') #=> {...}
    #
    # @example Find a non-existent cookbook
    #   Community.cookbook('not-real') #=> Community::BadResponse
    #
    # @raise [Community::BadResponse]
    #   if the given cookbook (or cookbook version) does not exist on the community site
    #
    # @param [String] name
    #   the name of the cookbook on the community site
    # @param [String] version (optional)
    #   the version of the cookbook to find
    #
    # @return [Hash]
    #   the hash of the cookbook
    #
    def cookbook(name, version = nil)
      if version.nil?
        connection.get("cookbooks/#{name}").body
      else
        connection.get("cookbooks/#{name}/versions/#{Util.version_for_url(version)}").body
      end
    end

    #
    # Upload a cookbook to the community site.
    #
    # @param [Cookbook] cookbook
    #   the cookbook to upload
    #
    def upload(cookbook)
      connection.post('cookbooks', {
        tarball:  Faraday::UploadIO.new(cookbook.tarball, 'application/x-tar'),
        cookbook: { category: cookbook.category }.to_json,
      })
    end

    private

    #
    # The Faraday connection object with lots of pretty middleware.
    #
    def connection
      @connection ||= Faraday.new(base_url) do |builder|
        # Enable multi-part requests (for uploading)
        builder.request :multipart
        builder.request :url_encoded

        # Encode request bodies as JSON
        builder.request :json

        # Add Mixlib authentication headers
        builder.use Stove::Middleware::ChefAuthentication, client, key

        # Handle any common errors
        builder.use Stove::Middleware::Exceptions

        # Decode responses as JSON if the Content-Type is json
        builder.response :json
        builder.response :json_fix

        # Allow up to 3 redirects
        builder.response :follow_redirects, limit: 3

        # Log all requests and responses (useful for development)
        builder.response :logger, log

        # Raise errors on 40x and 50x responses
        builder.response :raise_error

        # Use the default adapter (Net::HTTP)
        builder.adapter :net_http

        # Set the User-Agent header for logging purposes
        builder.headers[:user_agent] = Stove::USER_AGENT

        # Set some options, such as timeouts
        builder.options[:timeout]      = 30
        builder.options[:open_timeout] = 30
      end
    end

    #
    # The name of the client to use (by default, this is the username).
    #
    # @return [String]
    #
    def client
      Config[:community][:username]
    end

    #
    # The path to the key on disk for authentication with the community site.
    # If a relative path is given, it is expanded relative to the configuration
    # file on disk.
    #
    # @return [String]
    #   the path to the key on disk
    #
    def key
      File.expand_path(Config[:community][:key], Config.__path__)
    end
  end
end
