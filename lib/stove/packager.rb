require 'rubygems/package'
require 'fileutils'
require 'tempfile'
require 'zlib'

module Stove
  class Packager
    include Logify

    ACCEPTABLE_FILES = [
      '.foodcritic',
      'README.*',
      'CHANGELOG.*',
      'CONTRIBUTING.md',
      'MAINTAINERS.md',
      'metadata.json',
      'attributes/*.rb',
      'definitions/*.rb',
      'files/**/*',
      'libraries/**/*.rb',
      'providers/**/*.rb',
      'recipes/*.rb',
      'resources/**/*.rb',
      'templates/**/*',
    ].freeze

    ACCEPTABLE_FILES_LIST = ACCEPTABLE_FILES.join(',').freeze

    TMP_FILES = [
      /^(?:.*[\\\/])?\.[^\\\/]+\.sw[p-z]$/,
      /~$/,
    ].freeze

    # The cookbook to package.
    #
    # @erturn [Stove::Cookbook]
    attr_reader :cookbook

    # Whether to include the new extended metadata attributes.
    #
    # @return [true, false]
    attr_reader :extended_metadata

    # Create a new packager instance.
    #
    # @param [Stove::Cookbook]
    #   the cookbook to package
    # @param [true, false] extended_metadata
    #   include new extended metadata attributes
    def initialize(cookbook, extended_metadata = false)
      @cookbook = cookbook
      @extended_metadata = extended_metadata
    end

    # A map from physical file path to tarball file path
    #
    # @example
    #   # Assuming +cookbook.name+ is 'apt'
    #
    #   {
    #     '/home/user/apt-cookbook/metadata.json' => 'apt/metadata.json',
    #     '/home/user/apt-cookbook/README.md' => 'apt/README.md'
    #   }
    #
    # @return [Hash<String, String>]
    #   the map of file paths
    def packaging_slip
      root = File.expand_path(cookbook.path)
      path = File.join(root, "{#{ACCEPTABLE_FILES_LIST}}")

      Dir.glob(path, File::FNM_DOTMATCH)
        .reject { |path| %w(. ..).include?(File.basename(path)) }
        .reject { |path| TMP_FILES.any? { |regex| path.match(regex) } }
        .map    { |path| [path, path.sub(/^#{Regexp.escape(root)}/, cookbook.name)] }
        .reduce({}) do |map, (cookbook_file, tarball_file)|
          map[cookbook_file] = tarball_file
        map
      end
    end

    def tarball
      # Generate the metadata.json on the fly
      metadata_json = File.join(cookbook.path, 'metadata.json')
      json = JSON.fast_generate(cookbook.metadata.to_hash(extended_metadata))
      File.open(metadata_json, 'wb') { |f| f.write(json) }

      io  = tar(File.dirname(cookbook.path), packaging_slip)
      tgz = gzip(io)

      tempfile = Tempfile.new([cookbook.name, '.tar.gz'], Dir.tmpdir)
      tempfile.binmode

      while buffer = tgz.read(1024)
        tempfile.write(buffer)
      end

      tempfile.rewind
      tempfile
    ensure
      if defined?(metadata_json) && File.exist?(File.join(cookbook.path, 'metadata.rb'))
        File.delete(metadata_json)
      end
    end

    #
    # Create a tar file from the given root and packaging slip
    #
    # @param [String] root
    #   the root where the tar files are being created
    # @param [Hash<String, String>] slip
    #   the map from physical file path to tarball file path
    #
    # @return [StringIO]
    #   the io object that contains the tarball contents
    #
    def tar(root, slip)
      io = StringIO.new('', 'r+b')
      Gem::Package::TarWriter.new(io) do |tar|
        slip.each do |original_file, tarball_file|
          mode = File.stat(original_file).mode

          if File.directory?(original_file)
            tar.mkdir(tarball_file, mode)
          else
            tar.add_file(tarball_file, mode) do |tf|
              File.open(original_file, 'rb') { |f| tf.write(f.read) }
            end
          end
        end
      end

      io.rewind
      io
    end

    #
    # GZip the given IO object (like a File or StringIO).
    #
    # @param [IO] io
    #   the io object to gzip
    #
    # @return [IO]
    #   the gzipped IO object
    #
    def gzip(io)
      gz = StringIO.new('')
      z = Zlib::GzipWriter.new(gz)
      z.write(io.string)
      z.close

      # z was closed to write the gzip footer, so
      # now we need a new StringIO
      StringIO.new(gz.string)
    end
  end
end
