require 'diesel/middleware_builder'
require 'diesel/middleware_stack'

module Diesel
  class Endpoint
    attr_reader :name, :url, :request_method

    def initialize(name, url, request_method)
      @name, @url, @request_method = name, url, request_method
    end

    def middlewares
      @middlewares ||= []
    end

    def middleware_stack
      @middleware_stack ||= MiddlewareStack.new(middlewares)
    end

    def config_middleware(&block)
      builder = MiddlewareBuilder.new(middlewares)
      builder.build(&block)
    end
  end
end
