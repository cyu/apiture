module Diesel
  class Authenticator
    attr_reader :strategies

    def self.build(authorizations)
      strategies = authorizations.map do |auth|
        case auth.type
        when :oauth2
          require 'diesel/auth/oauth2'
          Diesel::Auth::OAuth2.build(auth)
        when :api_key
          require 'diesel/auth/api_key'
          Diesel::Auth::APIKey.build(auth)
        else
          raise "Unsupported authentication: #{auth.type}"
        end
      end

      new(strategies)
    end

    def initialize(strategies)
      @strategies = strategies
    end

    def activate(api_class)
      @strategies.each { |s| s.activate(api_class) }
    end

    def apply_filter(request, context)
      @strategies.each { |s| s.apply_filter(request, context) }
    end
  end
end

