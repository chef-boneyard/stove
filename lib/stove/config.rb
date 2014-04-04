require 'json'

module Stove
  class Config
    include Mixin::Instanceable
    include Logify

    #
    # Create a new configuration object. If a configuration file does not
    # exist, this method will output a warning to the UI and use an empty
    # hash as the data structure.
    #
    def initialize
      log.debug("Reading from config at `#{__path__}'")

      contents = File.read(__path__)
      data = JSON.parse(contents, symbolize_names: true)

      log.debug("Config:\n#{JSON.pretty_generate(sanitize(data))}")

      @data = data
    rescue Errno::ENOENT
      log.warn(<<-EOH.gsub(/^ {8}/, ''))
        No Stove configuration file found at `#{__path__}'. Stove will assume an
        empty configuration, which may cause problems with some plugins. It is
        recommended that you create a Stove configuration file as documented:

            https://github.com/sethvargo/stove#installation
      EOH

      @data = {}
    end

    #
    # This is a special key that tells me where stove lives. If you actually
    # have a key in your config called +__path__+, then it sucks to be you.
    #
    # @return [String]
    #
    def __path__
      @path ||= File.expand_path(ENV['STOVE_CONFIG'] || '~/.stove')
    end

    #
    # Deletegate all method calls to the underlyng hash.
    #
    def method_missing(m, *args, &block)
      @data.send(m, *args, &block)
    end

    private

    def sanitize(data)
      Hash[*data.map do |key, value|
        if value.is_a?(Hash)
          [key, sanitize(value)]
        else
          if key =~ /access|token|password/
            [key, '[FILTERED]']
          else
            [key, value]
          end
        end
      end.flatten(1)]
    end
  end
end
