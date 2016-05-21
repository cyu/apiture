require 'apiture/middleware_builder'
require 'apiture/middleware_stack'

module Apiture
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
