module Diesel
  module Middleware
    module Auth
      class OAuth2

        AUTHORIZATION_HEADER = 'Authorization'
        AUTHORIZATION_HEADER_FORMAT = 'Bearer %s'

        def initialize(app, options)
          @app = app
          @id = options[:id]
        end

        def call(env)
          context = env[:context]
          auth_options = context.options[@id]
          env[:request_headers][AUTHORIZATION_HEADER] = AUTHORIZATION_HEADER_FORMAT % auth_options[:token]
          @app.call(env)
        end

      end
    end
  end
end
