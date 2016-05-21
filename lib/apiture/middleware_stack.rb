module Apiture
  class MiddlewareStack

    def initialize(middlewares)
      cur = ->(env){}
      middlewares.reverse.each do |(klass, options)|
        cur = if klass.instance_method(:initialize).arity == 1
          klass.new(cur)
        else
          klass.new(cur, options)
        end
      end
      @first = cur
    end

    def call(env)
      @first.call(env)
    end

  end
end
