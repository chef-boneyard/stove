require 'httparty'

module Stove
  class CommunitySite
    include HTTParty
    base_uri 'https://cookbooks.opscode.com/api/v1'
    headers 'Content-Type' => 'application/json', 'Accept' => 'application/json'

    class << self
      # The URI for the web-based version of the site. (default:
      # https://community.opscode.com).
      #
      # If a parameter is given, the {http_uri} is set to that value.
      #
      # @return [String]
      def http_uri(arg = nil)
        if arg.nil?
          @http_uri ||= 'https://community.opscode.com'
        else
          @http_uri = arg
          @http_uri
        end
      end

      # Get and cache a community cookbook's JSON response from the given name
      # and version.
      #
      # @example Find a cookbook by name
      #   CommunitySite.cookbook('apache2') #=> {...}
      #
      # @example Find a cookbook by name and version
      #   CommunitySite.cookbook('apache2', '1.0.0') #=> {...}
      #
      # @example Find a non-existent cookbook
      #   CommunitySite.cookbook('not-real') #=> CommunitySite::BadResponse
      #
      # @raise [CommunitySite::BadResponse]
      #   if the given cookbook (or cookbook version) does not exist on the community site
      #
      # @param [String] name
      #   the name of the cookbook on the community site
      # @param [String] version (optional)
      #   the version of the cookbook to find
      def cookbook(name, version = nil)
        if version.nil?
          get("/cookbooks/#{name}")
        else
          get("/cookbooks/#{name}/versions/#{format_version(version)}")
        end
      end

      private
        # Convert a version string (x.y.z) to a community-site friendly format
        # (x_y_z).
        #
        # @example Convert a version to a version string
        #   format_version('1.2.3') #=> 1_2_3
        #
        # @param [#to_s] version
        #  the version string to convert
        #
        # @return [String]
        def format_version(version)
          version.gsub('.', '_')
        end

        # @override [HTTParty.get]
        def get(path, options = {}, &block)
          cache[path] ||= begin
            Stove::Logger.debug "Getting #{path}"
            response = super(path)
            raise Stove::BadResponse.new(response) unless response.ok?
            response.parsed_response
          end
        end

        # A small, unpersisted cache for storing responses
        #
        # @return [Hash]
        def cache
          @cache ||= {}
        end
    end
  end
end
