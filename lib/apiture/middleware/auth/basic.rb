module Apiture
  module Middleware
    module Auth
      class Basic

        AUTHORIZATION_HEADER = 'Authorization'.freeze

        def initialize(app, options)
          @app = app
          @id = options[:id]
        end

        def call(env)
          auth_options = env[:context].options[@id]
          env[:basic_auth] = {
            username: auth_options[:username],
            password: auth_options[:password]
          }
          @app.call(env)
        end

      end
    end
  end
end
