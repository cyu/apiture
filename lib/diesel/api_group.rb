require 'diesel/request_context'
require 'diesel/endpoint'

module Diesel
  class APIGroup
    attr_accessor :logger

    def endpoints; @endpoints ||= []; end
    def endpoints=(endpoints)
      @endpoints = endpoints
    end

    def authenticators; @authenticators; end
    def authenticators=(auth)
      @authenticators = auth
    end

    def data_models; @data_models ||= {}; end
    def data_models=(data_models)
      @data_models = data_models
    end

    def execute(options, endpoint, *parameters)
      params = parameters.last || {}
      RequestContext.new(options, self, endpoint, params).perform
    end
  end
end
