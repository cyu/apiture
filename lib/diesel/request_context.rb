module Diesel
  class RequestContext
    attr_reader :api, :endpoint, :attributes

    def initialize(api, endpoint, attributes)
      @api, @endpoint, @attributes = api, endpoint, attributes
    end

    def logger
      api.logger
    end

    def get_attribute(name)
      name = name.intern
      attributes[name] || endpoint.attributes[name][:default]
    end

    def endpoint_url
      url = api.class.base_uri.dup
      url << "/" unless url =~ /\/$/
      endpoint_path = endpoint.evaluated_path(self)
      url << (endpoint_path =~ /^\// ? endpoint_path[1..-1] : endpoint_path)
      url
    end

    def http_options
      Hash.new.tap do |h|
        h[:headers] = api.class.request_headers.dup
        if api.auth_strategy
          api.auth_strategy.set_http_options(self, h)
        end
      end
    end

    def perform
      endpoint.perform(self)
    end
  end
end
