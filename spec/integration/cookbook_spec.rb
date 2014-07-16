require 'spec_helper'

describe Stove::Cookbook do
  describe '#tarball' do
    it 'contains a directory with the same name as the cookbook' do
      FileUtils.mkdir_p('tmp/basic-cookbook/recipes')
      FileUtils.mkdir_p('tmp/basic-cookbook/templates/default')
      File.open('tmp/basic-cookbook/metadata.rb', 'w+') do |f|
        f.puts "name 'basic'"
      end
      File.open('tmp/basic-cookbook/recipes/default.rb', 'w+') do |f|
        f.puts '# default.rb'
      end
      File.open('tmp/basic-cookbook/templates/default/basic.erb', 'w+') do |f|
        f.puts '# basic.erb'
      end

      tarball = Stove::Cookbook.new('tmp/basic-cookbook').tarball
      tarball_directories = []

      Zlib::GzipReader.open(tarball.path) do |gzip|
        Gem::Package::TarReader.new(gzip) do |tar|
          tarball_directories = tar.map(&:full_name).map(&File.method(:dirname))
        end
      end

      expect(tarball_directories.uniq).to eql([
        'basic',
        'basic/recipes',
        'basic/templates',
        'basic/templates/default'
      ])
    end
  end
end
