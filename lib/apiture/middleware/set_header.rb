module Apiture
  module Middleware
    class SetHeader
      def initialize(app, headers)
        @app = app
        @headers = headers
      end

      def call(env)
        env[:request_headers].merge!(@headers)
        @app.call(env)
      end
    end
  end
end
