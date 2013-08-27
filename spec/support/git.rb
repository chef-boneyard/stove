require 'fileutils'

module Stove
  module RSpec
    module Git
      include Stove::Git

      def git_init(path = Dir.pwd)
        Dir.chdir(path) do
          git 'init .'
          git 'add --all'
          git 'commit --message "Initial commit"'
          git 'remote add origin file://' + fake_git_remote
        end
      end

      def fake_git_remote
        path = File.expand_path(File.join(tmp_path, 'remote.git'))
        return path if File.exists?(path)

        FileUtils.mkdir_p(path)
        Dir.chdir(path) do
          git 'init .'
          git 'config receive.denyCurrentBranch ignore'
          git 'config receive.denyNonFastforwards true'
          git 'config core.sharedrepository 1'
        end

        path
      end

      def git_shas(path)
        Dir.chdir(path) do
          git('log --oneline').split("\n").map { |line| line.split(/\s+/, 2).first.strip } rescue []
        end
      end

      def git_commits(path)
        Dir.chdir(path) do
          git('log --oneline').split("\n").map { |line| line.split(/\s+/, 2).last.strip } rescue []
        end
      end

      def git_tags(path)
        Dir.chdir(path) do
          git('tag --list').split("\n").map(&:strip) rescue []
        end
      end
    end
  end
end
