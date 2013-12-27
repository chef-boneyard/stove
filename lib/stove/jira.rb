require 'faraday'
require 'faraday_middleware'

module Stove
  class JIRA
    include Mixin::Instanceable
    include Mixin::Loggable
    include Mixin::Optionable

    option :base_url,
      ENV['JIRA_URL'] || 'https://tickets.opscode.com/rest/api/2'

    def issue(key, options = {})
      connection.get("issue/#{key}", options).body
    end

    def search(query = {})
      jql = query.map { |k,v| %Q|#{k} = "#{v}"| }.join(' AND ')
      connection.get('search', jql: jql).body
    end

    def close_and_comment(key, comment)
      transitions = issue(key, expand: 'transitions')['transitions']
      close = transitions.first { |transition| transition['name'] == 'Close' }

      if close.nil?
        log.warn("Issue #{key} does not have a `Close' transition")
        return
      end

      connection.post("issue/#{key}/transitions", {
        transition: { id: close['id'] },
        update: {
          comment: [
            { add: { body: comment.to_s } }
          ]
        },
        fields: {
          resolution: {
            name: 'Fixed'
          },
          assignee: {
            name: nil
          }
        }
      })
    end

    private

    def connection
      @connection ||= Faraday.new(base_url) do |builder|
        # Encode request bodies as JSON
        builder.request :json

        # Add basic authentication information
        builder.request :basic_auth, Stove::Config[:jira][:username],
                                     Stove::Config[:jira][:password]

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
  end
end
