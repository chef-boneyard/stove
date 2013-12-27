require 'fileutils'

module Stove
  module Git
    def git_init(path = Dir.pwd)
      cmd = [
        'cd "' + path + '"',
        'git init .',
        'git add --all',
        'git commit --message "Initial commit"',
        'git remote add origin file://' + fake_git_remote,
        'git push --quiet --force origin master',
      ].join(' && ')

      %x|#{cmd}|
    end

    def fake_git_remote
      path = File.expand_path(File.join(tmp_path, 'remote.git'))
      return path if File.exists?(path)

      FileUtils.mkdir_p(path)
      cmd = [
        'cd "' + path + '"',
        'git init .',
        'git config receive.denyCurrentBranch ignore',
        'git config receive.denyNonFastforwards true',
        'git config core.sharedrepository 1',
      ].join(' && ')

      %x|#{cmd}|

      path
    end

    def git_shas(path)
      %x|cd "#{path}" && git log --oneline|.split("\n").map { |line| line.split(/\s+/, 2).first.strip } rescue []
    end

    def git_commits(path)
      %x|cd "#{path}" && git log --oneline|.split("\n").map { |line| line.split(/\s+/, 2).last.strip } rescue []
    end

    def git_tags(path)
      %x|cd "#{path}" && git tag --list|.split("\n").map(&:strip) rescue []
    end
  end
end
