require 'diesel/inflections'

module Diesel
  class RequestContext
    include Inflections

    attr_reader :api, :endpoint, :attributes

    def initialize(api, endpoint, attributes)
      @api, @endpoint, @attributes = api, endpoint, attributes
    end

    def logger
      api.logger
    end

    def get_attribute(name)
      name = name.to_sym
      unless attributes.has_key?(name)
        name = underscore(name).to_sym
      end
      attributes[name]
    end

    def endpoint_url
      url = api.class.base_path.dup
      url << "/" unless url =~ /\/$/
      endpoint_path = endpoint.path
      url << (endpoint_path =~ /^\// ? endpoint_path[1..-1] : endpoint_path)
      url
    end

    def perform
      endpoint.perform(self)
    end
  end
end
