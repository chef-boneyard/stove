module Stove
  class Middleware::Exceptions < Faraday::Middleware
    include Logify

    def call(env)
      begin
        @app.call(env)
      rescue Faraday::Error::ConnectionFailed
        url = env[:url].to_s.gsub(env[:url].path, '')
        raise Error::ServerUnavailable.new(url: url)
      rescue Faraday::Error::ClientError => e
        log.debug(env.inspect)
        raise
      end
    end
  end
end
