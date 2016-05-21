require 'httparty'
require 'apiture/utils/inflections'

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
        headers = env[:request_headers].reject { |_,v| v.nil? }
        HTTParty.send(env[:method],
                      env[:url].to_s,
                      headers: headers,
                      query: env[:params],
                      body: env[:body])
      end
  end
end
