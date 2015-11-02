module Diesel
  module Middleware
    class ConvertJSONBody
      def initialize(app)
        @app = app
      end
      def call(env)
        @app.call(env)
        if body = env[:body]
          env[:body] = MultiJson.dump(body)
        end
      end
    end
  end
end
