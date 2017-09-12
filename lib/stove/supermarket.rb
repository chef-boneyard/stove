require 'chef-api'

module Stove
  class Supermarket
    include Mixin::Instanceable
    include Mixin::Optionable

    #
    # The default endpoint where the Supermarket lives.
    #
    # @return [String]
    #
    DEFAULT_ENDPOINT = 'https://supermarket.chef.io/api/v1'

    #
    # Get and cache a community cookbook's JSON response from the given name
    # and version.
    #
    # @example Find a cookbook by name
    #   Supermarket.cookbook('apache2') #=> {...}
    #
    # @example Find a cookbook by name and version
    #   Supermarket.cookbook('apache2', '1.0.0') #=> {...}
    #
    # @example Find a non-existent cookbook
    #   Supermarket.cookbook('not-real') #=> Community::BadResponse
    #
    # @raise [Supermarket::BadResponse]
    #   if the given cookbook (or cookbook version) does not exist on the Supermarket
    #
    # @param [String] name
    #   the name of the cookbook on the Supermarket
    # @param [String] version (optional)
    #   the version of the cookbook to find
    #
    # @return [Hash]
    #   the hash of the cookbook
    #
    def cookbook(name, version = nil)
      if version.nil?
        connection.get("cookbooks/#{name}")
      else
        connection.get("cookbooks/#{name}/versions/#{Util.version_for_url(version)}")
      end
    end

    #
    # Upload a cookbook to the community site.
    #
    # @param [Cookbook] cookbook
    #   the cookbook to upload
    #
    def upload(cookbook, extended_metadata = false)
      connection.post('cookbooks', {
        'tarball'  => cookbook.tarball(extended_metadata),

        # This is for legacy, backwards-compatability reasons. The new
        # Supermarket site does not require a category, but many of the testing
        # tools still assume a cookbook category is present. We just hardcode
        # "Other" here.
        'cookbook' => JSON.fast_generate(category: 'Other'),
      })
    end

    #
    # Delete the given cookbook from the supermarket.
    #
    # @param [String] name
    #   the name of the cookbook to delete
    #
    # @return [true, false]
    #   true if the cookbook was deleted, false otherwise
    #
    def yank(name)
      connection.delete("/cookbooks/#{name}")
      true
    rescue ChefAPI::Error::HTTPBadRequest,
           ChefAPI::Error::HTTPNotFound,
      false
    end

    private

    #
    # The ChefAPI connection object with lots of pretty middleware.
    #
    def connection
      @connection ||= ChefAPI::Connection.new do |conn|
        conn.endpoint   = ENV['STOVE_ENDPOINT']      || Config.endpoint || DEFAULT_ENDPOINT
        conn.client     = ENV['STOVE_USERNAME']      || Config.username
        conn.key        = ENV['STOVE_KEY']           || Config.key
        conn.ssl_verify = ENV['STOVE_NO_SSL_VERIFY'] || Config.ssl_verify
      end
    end
  end
end
