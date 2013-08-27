require 'jiralicious'
require 'json'

module Stove
  class JIRA
    JIRA_URL = 'https://tickets.opscode.com'

    Jiralicious.configure do |config|
      config.username = Stove::Config['jira_username']
      config.password = Stove::Config['jira_password']
      config.uri      = JIRA_URL
    end

    class << self
      def unreleased_tickets_for(component)
        jql = [
          'project = COOK',
          'resolution = Fixed',
          'status = "Fix Committed"',
          'component = ' + component.inspect
        ].join(' AND ')
        Stove::Logger.debug "JQL: #{jql.inspect}"

        Jiralicious.search(jql).issues
      end

      # Comment and close a particular issue.
      #
      # @param [Jiralicious::Issue] ticket
      #   the JIRA ticket
      # @param [Stove::Cookbook] cookbook
      #   the cookbook to release
      def comment_and_close(ticket, cookbook)
        comment = "Released in [#{cookbook.version}|#{cookbook.url}]"

        transition = Jiralicious::Issue::Transitions.find(ticket.jira_key).find do |key, value|
          !value.is_a?(String) && value.name == 'Close'
        end.last

        Jiralicious::Issue::Transitions.go(ticket.jira_key, transition.id, { comment: comment })
      end
    end
  end
end
