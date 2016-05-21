module Apiture
  module Middleware
    class Debug
      def initialize(app)
        @app = app
      end
      def call(env)
        @app.call(env)
        logger = env[:logger]
        if logger && logger.debug?
          logger.debug("Request Method: #{env[:method]}")
          logger.debug("URL: #{env[:url]}")
          logger.debug("Request Headers: #{env[:request_headers].inspect}")
          logger.debug("Params: #{env[:params].inspect}")
          logger.debug("Body: #{env[:body]}")
        end
      end
    end
  end
end
