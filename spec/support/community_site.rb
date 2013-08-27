require 'community_zero/server'

module Stove
  module RSpec
    module CommunitySite
      class << self
        def start(options = {})
          return @server if @server

          @server = CommunityZero::Server.new(options)
          @server.start_background
          @server
        end

        def stop
          @server.stop if running?
        end

        def running?
          !!(@server && @server.running?)
        end

        def reset!
          @server && @server.reset!
        end

        def server_url
          @server && @server.url
        end
      end
    end
  end
end
