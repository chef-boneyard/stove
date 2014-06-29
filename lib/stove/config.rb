require 'fileutils'
require 'json'

module Stove
  class Config
    include Logify
    include Mixin::Instanceable

    def method_missing(m, *args, &block)
      if m.to_s.end_with?('=')
        __set__(m.to_s.chomp('='), args.first)
      else
        __get__(m)
      end
    end

    def respond_to_missing?(m, include_private = false)
      __has__?(m) || super
    end

    def save
      FileUtils.mkdir_p(File.dirname(__path__))
      File.open(__path__, 'w') do |f|
        f.write(JSON.fast_generate(__raw__))
      end
    end

    def to_s
      "#<#{self.class.name} #{__raw__.to_s}>"
    end

    def inspect
      "#<#{self.class.name} #{__raw__.inspect}>"
    end

    def __get__(key)
      __raw__[key.to_sym]
    end

    def __has__?(key)
      __raw__.key?(key.to_sym)
    end

    def __set__(key, value)
      __raw__[key.to_sym] = value
    end

    def __unset__(key)
      __raw__.delete(key.to_sym)
    end

    def __path__
      @path ||= File.expand_path(ENV['STOVE_CONFIG'] || '~/.stove')
    end

    def __raw__
      return @__raw__ if @__raw__

      @__raw__ = JSON.parse(File.read(__path__), symbolize_names: true)

      if @__raw__.key?(:community)
        $stderr.puts "Detected old Stove configuration file, converting..."

        @__raw__ = {
          :username => @__raw__[:community][:username],
          :key      => @__raw__[:community][:key],
        }
      end

      @__raw__
    rescue Errno::ENOENT => e
      log.warn { "No config file found at `#{__path__}'!" }
      @__raw__ = {}
    end
  end
end
