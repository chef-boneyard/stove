require 'pp'

module Stove
  class Middleware::ChefAuthentication < Faraday::Middleware
    dependency do
      require 'mixlib/authentication/signedheaderauth'
      require 'openssl'
      require 'uri'
    end

    #
    # @param [Faraday::Application] app
    # @param [String] client
    #   the name of the client to use for Chef
    # @param [OpenSSL::PKey::RSA] key
    #   the RSA private key to sign with
    #
    def initialize(app, client, key)
      super(app)

      @client = client
      @key    = OpenSSL::PKey::RSA.new(File.read(key))
    end

    def call(env)
      env[:request_headers].merge!(signing_object(env))
      @app.call(env)
    end

    private

    def signing_object(env)
      params = {
        :http_method => env[:method],
        :timestamp   => Time.now.utc.iso8601,
        :user_id     => @client,
        :path        => env[:url].path,
        :body        => env[:body] || '',
      }

      # Royal fucking hack
      #   1. (n.) This code sample
      #   2. (v.) Having to decompose a Faraday response because Mixlib
      #           Authentication couldn't get a date to the prom
      if env[:body] && env[:body].is_a?(Faraday::CompositeReadIO)
        file = env[:body]
          .instance_variable_get(:@parts)
          .first { |part| part.is_a?(Faraday::Parts::FilePart) }
          .instance_variable_get(:@io)
          .instance_variable_get(:@ios)[1]
          .instance_variable_get(:@local_path)

        params[:file] = File.new(file)
      end

      object = Mixlib::Authentication::SignedHeaderAuth.signing_object(params)
      object.sign(@key)
    end
  end
end
