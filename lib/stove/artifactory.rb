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
      base_uri_string = Config.artifactory.strip
      base_uri_string << '/' unless base_uri_string.end_with?('/')
      base_uri = URI(base_uri_string)

      # Open the HTTP connection to artifactory.
      connection = Net::HTTP.new(base_uri.host, base_uri.port)
      if base_uri.scheme == 'https'
        connection.use_ssl = true
        # Mimic the behavior of the Cookbook uploader for SSL verification.
        if ENV['STOVE_NO_SSL_VERIFY'] || !Config.ssl_verify
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      connection.start do |http|
        # Artifactory doesn't prevent uploading over an existing release in
        # some cases so let's check for that. Seriously never do this, go delete
        # and then re-upload if you have to.
        check_uri = URI("#{base_uri}api/v1/cookbooks/#{cookbook.name}/versions/#{cookbook.version}")
        check_request = Net::HTTP::Get.new(check_uri)
        check_request['X-Jfrog-Art-Api'] = Config.artifactory_key.strip
        response = http.request(check_request)
        # Artifactory's version of the cookbook_version endpoint returns an
        # empty 200 on an unknown version.
        if response.code != '200' || !response.body.empty?
          raise Error::CookbookAlreadyExists.new(cookbook: cookbook)
        end

        upload_uri = URI("#{base_uri}api/v1/cookbooks/#{cookbook.name}.tgz")
        upload_request = Net::HTTP::Post.new(upload_uri)
        upload_request.body_stream = cookbook.tarball(extended_metadata)
        upload_request.content_length = upload_request.body_stream.size
        upload_request['Content-Type'] = 'application/x-binary'
        upload_request['X-Jfrog-Art-Api'] = Config.artifactory_key.strip
        response = http.request(upload_request)
        if response.code != '201'
          response.error!
        end
      end
    end

  end
end
