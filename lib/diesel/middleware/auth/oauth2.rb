module Diesel
  module Middleware
    module Auth
      class OAuth2

        AUTHORIZATION_HEADER = 'Authorization'
        AUTHORIZATION_HEADER_FORMAT = 'Bearer %s'

        def initialize(app, options)
          @app = app
          @id = options[:id]
          @in = options[:in]
          @name = options[:name]
        end

        def call(env)
          context = env[:context]
          auth_options = context.options[@id]
          token = auth_options[:token]
          if @in == :query
            env[:params][@name] = token
          else
            env[:request_headers][AUTHORIZATION_HEADER] = AUTHORIZATION_HEADER_FORMAT % token
          end
          @app.call(env)
        end

      end
    end
  end
end
