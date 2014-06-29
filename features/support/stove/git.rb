require 'fileutils'

module Stove
  module Git
    def git_init(path = Dir.pwd)
      cmd = [
        'git init .',
        'git add --all',
        'git commit --message "Initial commit"',
        'git remote add origin file://' + fake_git_remote,
        'git push --quiet --force origin master',
      ].join(' && ')

      Dir.chdir(path) do
        %x|#{cmd}|
      end
    end

    def fake_git_remote
      path = File.expand_path(File.join(remotes_path, 'remote.git'))
      return path if File.exists?(path)

      FileUtils.mkdir_p(path)
      cmd = [
        'git init .',
        'git config receive.denyCurrentBranch ignore',
        'git config receive.denyNonFastforwards true',
        'git config core.sharedrepository 1',
      ].join(' && ')

      Dir.chdir(path) do
        %x|#{cmd}|
      end

      path
    end

    def git_shas(path)
      Dir.chdir(path) do
        %x|git log --oneline|.split("\n").map { |line| line.split(/\s+/, 2).first.strip } rescue []
      end
    end

    def git_commits(path)
      Dir.chdir(path) do
        %x|git log --oneline|.split("\n").map { |line| line.split(/\s+/, 2).last.strip } rescue []
      end
    end

    def git_tags(path)
      Dir.chdir(path) do
        %x|git tag --list|.split("\n").map(&:strip) rescue []
      end
    end

    def git_tag_signature?(path, tag)
      Dir.chdir(path) do
        %x|git show --show-signature #{tag}|.include?('BEGIN PGP SIGNATURE') rescue false
      end
    end

    private

    def remotes_path
      @remotes_path ||= File.join(scratch_dir, 'remotes')
    end
  end
end
