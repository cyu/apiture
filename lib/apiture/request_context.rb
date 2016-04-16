require 'faraday'
require 'faraday_middleware'
require 'apiture/utils/inflections'

module FaradayMiddleware
  class ParseJsonWithQuirksMode < ParseJson
    define_parser do |body|
      ::JSON.parse(body, quirks_mode: true) unless body.strip.empty?
    end
  end
end
Faraday::Response.register_middleware json_quirks: lambda { FaradayMiddleware::ParseJsonWithQuirksMode }

module Apiture
  class RequestContext
    include Apiture::Utils::Inflections

    attr_reader :options, :group, :endpoint, :attributes

    def initialize(options, group, endpoint, attributes)
      @options, @group, @endpoint, @attributes = options, group, endpoint, attributes
    end

    def perform
      url = endpoint.url.dup

      if url.base_host
        url.subdomain = options[:subdomain]
      end

      env = {
        method: endpoint.request_method,
        url: url,
        params: {},
        request_headers: {},
        logger: logger,
        context: self
      }

      endpoint.middleware_stack.call(env)
      perform_request(env)
    end

    def authenticator
      group.authenticator
    end

    def logger
      group.logger
    end

    def get_attribute(name)
      name = name.to_sym
      unless attributes.has_key?(name)
        name = underscore(name).to_sym
      end
      attributes[name]
    end

    protected
      def perform_request(env)
        request_method = env[:method] ? env[:method].to_sym : :get
        headers = env[:request_headers]

        conn = Faraday.new do |faraday|
          faraday.adapter Faraday.default_adapter
          configure_format_handlers(faraday, headers)
        end

        if auth = env[:basic_auth]
          conn.basic_auth(auth[:username], auth[:password])
        end

        conn.__send__(request_method) do |req|
          req.url env[:url].to_s, env[:params]
          req.headers.merge!(headers) if headers
          if body = env[:body]
            req.body = body
          end
        end
      end

      def configure_format_handlers(conn, headers)
        if headers && accept = headers["Accept"]
          content_types = accept.split(",").map { |s| s.split(";").first.strip }
          content_types.each do |type|
            content_type_mappings.each do |(parser, type_match)|
              if type.match(type_match)
                conn.response(parser, content_type: type_match)
              end
            end
          end
        end
      end

      def content_type_mappings
        [
          [:xml, /\bxml$/],
          [:json_quirks, /\bjson$/]
        ]
      end
  end
end
