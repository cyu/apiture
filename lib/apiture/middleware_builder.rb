module Apiture
  class MiddlewareBuilder
    def initialize(middlewares)
      @middlewares = middlewares
    end

    def build(&block)
      instance_eval(&block)
    end

    def use(middleware_klass, options = {})
      @middlewares << [middleware_klass, options]
    end
  end
end
