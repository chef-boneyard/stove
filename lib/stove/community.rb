require 'chef-api'

module Stove
  class Community
    include Mixin::Instanceable
    include Mixin::Optionable

    #
    # The default endpoint where the community site lives.
    #
    # @return [String]
    #
    DEFAULT_ENDPOINT = 'https://supermarket.chef.io/api/v1'

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
    # Delete the given cookbook from the communit site.
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
        conn.endpoint      = ENV['STOVE_ENDPOINT']      || Config.endpoint || DEFAULT_ENDPOINT
        conn.client        = ENV['STOVE_USERNAME']      || Config.username
        conn.key           = ENV['STOVE_KEY']           || Config.key
        conn.proxy_address = ENV['STOVE_PROXY_ADDRESS'] || Config.proxy_address
        conn.proxy_port    = ENV['STOVE_PROXY_PORT']    || Config.proxy_port
      end
    end
  end
end
