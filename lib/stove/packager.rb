require 'archive/tar/minitar'
require 'fileutils'
require 'tmpdir'
require 'tempfile'
require 'zlib'

module Stove
  class Packager
    ACCEPTABLE_FILES = [
      'README.*',
      'CHANGELOG.*',
      'metadata.{json,rb}',
      'attributes',
      'definitions',
      'files',
      'libraries',
      'providers',
      'recipes',
      'resources',
      'templates',
    ]

    # The cookbook to package.
    #
    # @erturn [Stove::Cookbook]
    attr_reader :cookbook

    # Create a new packager instance.
    #
    # @param [Stove::Cookbook]
    #   the cookbook to package
    def initialize(cookbook)
      @cookbook = cookbook
    end

    # The list of files that should actually be uploaded.
    #
    # @return [Array]
    #   the array of file paths
    def cookbook_files
      Dir.glob("#{File.expand_path(cookbook.path)}/{#{ACCEPTABLE_FILES.join(',')}}")
    end

    # The path to the tar.gz package in the temporary directory.
    #
    # @return [String]
    def package_path
      pack!
    end

    private

    def pack!
      destination = Tempfile.new(cookbook.name).path

      # Sandbox
      sandbox = Dir.mktmpdir
      FileUtils.mkdir_p(sandbox)

      # Containing folder
      container = File.join(sandbox, cookbook.name)
      FileUtils.mkdir_p(container)

      # Copy filles
      FileUtils.cp_r(cookbook_files, container)

      # Generate metadata
      File.open(File.join(container, 'metadata.json'), 'w') do |f|
        f.write(cookbook.metadata.to_json)
      end

      Dir.chdir(sandbox) do |dir|
        # This is super fucking annoying. The community site should really
        # be better at reading tarballs
        relative_path = container.gsub(sandbox + '/', '') + '/'
        tgz = Zlib::GzipWriter.new(File.open(destination, 'wb'))
        Archive::Tar::Minitar.pack(relative_path, tgz)
      end

      return destination
    end
  end
end
