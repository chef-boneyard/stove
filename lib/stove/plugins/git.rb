module Stove
  class Plugin::Git < Plugin::Base
    id 'git'
    description 'Tag and push to a git remote'

    validate(:repository) do
      File.directory?(File.join(Dir.pwd, '.git'))
    end

    validate(:clean) do
      git_null('status --porcelain').strip.empty?
    end

    validate(:up_to_date) do
      git_null('fetch')
      local_sha  = git_null("rev-parse #{branch}").strip
      remote_sha = git_null("rev-parse #{remote}/#{branch}").strip

      log.debug("Local SHA: #{local_sha}")
      log.debug("Remote SHA: #{remote_sha}")

      local_sha == remote_sha
    end

    run('Tagging new release') do
      annotation_type = options[:sign] ? '-s' : '-a'
      tag = cookbook.tag_version

      git %|tag #{annotation_type} #{tag} -m "Release #{tag}"|
      git %|push #{remote} #{branch}|
      git %|push #{remote} #{tag}|
    end

    private

    def git(command, errors = true)
      log.debug("the command matches")
      log.debug("Running `git #{command}', errors: #{errors}")
      Dir.chdir(cookbook.path) do
        response = %x|git #{command}|

        if errors && !$?.success?
          raise Error::GitTaggingFailed.new(command: command) if command =~ /^tag/
          raise Error::GitFailed.new(command: command)
        end

        response
      end
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

    def remote
      options[:remote]
    end

    def branch
      options[:branch]
    end
  end
end
