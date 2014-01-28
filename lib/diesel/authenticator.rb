module Diesel
  class Authenticator
    attr_accessor :strategy, :options

    def self.create(type, options = {})
      strategy = case type
      when :oauth2
        require 'diesel/auth/oauth2'
        Diesel::Auth::OAuth2
      when :http_header
        require 'diesel/auth/http_header'
        Diesel::Auth::HTTPHeader
      else
        raise "Unsupported authentication: #{type}"
      end

      new(strategy, options)
    end

    def initialize(strategy, options)
      @strategy, @options = strategy, options
    end

    def activate(api)
      @strategy.activate(api, options)
    end

    def create_strategy(api)
      @strategy.new(api, options)
    end
  end
end

