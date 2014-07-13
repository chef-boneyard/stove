require 'spec_helper'

describe Stove::Cookbook do
  describe '#tarball' do
    it 'contains a directory with the same name as the cookbook' do
      FileUtils.mkdir_p('tmp/basic-cookbook')
      File.open('tmp/basic-cookbook/metadata.rb', 'w+') do |f|
        f.puts "name 'basic'"
      end

      tarball = Stove::Cookbook.new('tmp/basic-cookbook').tarball
      tarball_directories = []

      Zlib::GzipReader.open(tarball.path) do |gzip|
        Gem::Package::TarReader.new(gzip) do |tar|
          tarball_directories = tar.map(&:full_name).map(&File.method(:dirname))
        end
      end

      expect(tarball_directories).to include('basic')
    end
  end
end
