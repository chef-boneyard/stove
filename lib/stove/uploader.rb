require 'httparty'
require 'httmultiparty'
require 'mixlib/authentication/signedheaderauth'
require 'openssl'

module Stove
  class Uploader
    include HTTMultiParty

    # The cookbook associated with this uploader
    #
    # @return [Stove::Cookbook]
    attr_reader :cookbook

    # Create a new uploader instance for the given cookbook.
    #
    # @param [Stove::Cookbook] cookbook
    #   the cookbook for this uploader
    def initialize(cookbook)
      @cookbook = cookbook
    end

    def upload!
      response = self.class.post(upload_url, {
        :headers => headers,
        :query   => {
          :tarball  => File.new(tarball),
          :cookbook => { category: cookbook.category }.to_json,
        },
      })

      if response.success?
        Stove.formatter.upload(cookbook)
      else
        raise Stove::UploadError.new(response)
      end
    end

    private
      def headers
        {
          'Accept' => 'application/json',
        }.merge(Mixlib::Authentication::SignedHeaderAuth.signing_object({
          :http_method => 'post',
          :timestamp   => Time.now.utc.iso8601,
          :user_id     => username,
          :path        => URI.parse(upload_url).path,
          :file        => File.new(tarball),
        }).sign(pem_file))
      end

      # So there's this really really crazy bug that the tmp directory could
      # be deleted mid-request...
      def tarball
        begin
          tgz = Stove::Packager.new(cookbook).package_path
        end until File.exists?(tgz)
        tgz
      end

      def pem_file
        OpenSSL::PKey::RSA.new(File.read(File.expand_path(Stove::Config['opscode_pem_file'])))
      end

      def username
        Stove::Config['opscode_username']
      end

      def upload_url
        "#{Stove::CommunitySite.base_uri}/cookbooks"
      end
  end
end
