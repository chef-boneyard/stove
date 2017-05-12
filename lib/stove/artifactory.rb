require 'net/http'

module Stove
  class Artifactory
    include Mixin::Instanceable

    #
    # Upload a cookbook to an Artifactory server.
    #
    # @param [Cookbook] cookbook
    #   the cookbook to upload
    #
    def upload(cookbook, extended_metadata = false)
      # Artifactory doesn't prevent uploading over an existing release in
      # some cases so let's check for that. Seriously never do this, go delete
      # and then re-upload if you have to.
      response = request(:get, "api/v1/cookbooks/#{cookbook.name}/versions/#{cookbook.version}")
      # Artifactory's version of the cookbook_version endpoint returns an
      # empty 200 on an unknown version.
      unless response.code == '404' || (response.code == '200' && response.body.to_s == '')
        raise Error::CookbookAlreadyExists.new(cookbook: cookbook)
      end

      # Run the upload.
      response = request(:post, "api/v1/cookbooks/#{cookbook.name}.tgz") do |req|
        req.body_stream = cookbook.tarball(extended_metadata)
        req.content_length = req.body_stream.size
        req['Content-Type'] = 'application/x-binary'
      end
      response.error! unless response.code == '201'
    end

    private

    #
    # Create an HTTP connect to the Artifactory server.
    #
    # @return [Net::HTTP]
    #
    def connection
      @connection ||= begin
        uri = URI(Config.artifactory.strip)
        # Open the HTTP connection to artifactory.
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          # Mimic the behavior of the Cookbook uploader for SSL verification.
          if ENV['STOVE_NO_SSL_VERIFY'] || !Config.ssl_verify
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
        http.start
      end
    end

    #
    # Send an HTTP request to the Artifactory server.
    #
    # @param [Symbol] method
    #   HTTP method to use
    #
    # @param [String] path
    #   URI path to request
    #
    # @param [Proc] block
    #   Optional block to set request values
    #
    # @return [Net::HTTPResponse]
    #
    def request(method, path, &block)
      uri_string = Config.artifactory.strip
      # Make sure we end up with the right number of separators.
      uri_string << '/' unless uri_string.end_with?('/')
      uri_string << path
      uri = URI(uri_string)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
      request['X-Jfrog-Art-Api'] = Config.artifactory_key.strip
      block.call(request) if block
      connection.request(request)
    end

  end
end
