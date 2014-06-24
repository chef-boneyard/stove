module Stove
  class Plugin::Git < Plugin::Base
    id 'git'
    description 'Tag and push to a git remote'

    validate(:repository) do
      File.directory?(File.join(Dir.pwd, '.git'))
    end

    validate(:clean) do
      git_null('status -s').strip.empty?
    end

    validate(:up_to_date) do
      git_null('fetch')
      local  = git_null("rev-parse #{options[:branch]}").strip
      remote = git_null("rev-parse #{options[:remote]}/#{options[:branch]}").strip

      log.debug("Local SHA: #{local}")
      log.debug("Remote SHA: #{remote}")

      local == remote
    end

    after(:bump, 'Performing version bump') do
      git %|add metadata.rb|
      git %|commit -m "Version bump to #{cookbook.version}"|
    end

    after(:changelog, 'Committing CHANGELOG') do
      git %|add CHANGELOG.md|
      git %|commit -m "Publish #{cookbook.version} Changelog"|
    end

    before(:upload, 'Tagging new release') do
      annotation_type = (Config[:git] && Config[:git][:sign_tags]) ? '-s' : '-a'
      git %|tag #{annotation_type} #{cookbook.tag_version} -m "Release #{cookbook.tag_version}"|
      git %|push #{options[:remote]} #{cookbook.tag_version}|
    end

    after(:dev, 'Bumping devodd release') do
      git %|add metadata.rb|
      git %|commit -m "Version bump to #{cookbook.version} (for development)"|
    end

    before(:finish, 'Pushing to git remote(s)') do
      git %|push #{options[:remote]} #{options[:branch]}|
    end

    def git(command, errors = true)
      log.debug("Running `git #{command}', errors: #{errors}")
      response = %x|cd "#{cookbook.path}" && git #{command}|

      if errors && !$?.success?
        raise Error::GitFailed.new(command: command)
      end

      response
    end

    def git_null(command)
      null = case RbConfig::CONFIG['host_os']
             when /mswin|mingw|cygwin/
               'NUL'
             else
               '/dev/null'
             end

      git("#{command} 2>#{null}", false)
    end
  end
end
