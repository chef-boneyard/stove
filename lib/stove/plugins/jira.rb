module Stove
  class Plugin::JIRA < Plugin::Base
    id 'jira'
    description 'Resolve JIRA issues'

    validate(:configuration) do
      Config.has_key?(:jira)
    end

    validate(:username) do
      Config[:jira].has_key?(:username)
    end

    validate(:password) do
      Config[:jira].has_key?(:password)
    end

    before(:changelog, 'Generate JIRA changeset') do
      by_type = unreleased_issues.inject({}) do |hash, issue|
        type = issue['fields']['issuetype']['name']
        hash[type] ||= []
        hash[type] << {
          key:     issue['key'],
          summary: issue['fields']['summary'],
        }

        hash
      end

      # Calculate the JIRA path based off of the JIRA base_url
      jira_base = URI.parse(JIRA.base_url)
      jira_base.path = ''
      jira_base = jira_base.to_s
      log.debug("JIRA base is `#{jira_base}'")

      contents = []

      by_type.each do |type, issues|
        contents << "### #{type}"
        issues.sort { |a, b| b[:key].to_i <=> a[:key].to_i }.each do |issue|
          url = "#{jira_base}/browse/#{issue[:key]}"
          contents << "- **[#{issue[:key]}](#{url})** - #{issue[:summary]}"
        end
        contents << ''
      end

      cookbook.changeset = contents.join("\n")
    end

    after(:upload, 'Resolving JIRA issues') do
      unreleased_issues.collect do |issue|
        Thread.new do
          JIRA.close_and_comment(issue['key'], "Released in #{cookbook.version}")
        end
      end.map(&:join)
    end

    #
    # The list of unreleased tickets on JIRA.
    #
    # @return [Array<Hash>]
    #
    def unreleased_issues
      @unreleased_issues ||= JIRA.search(
        project:    'COOK',
        resolution: 'Fixed',
        status:     'Fix Committed',
        component:  cookbook.name,
      )['issues']
    end
  end
end
