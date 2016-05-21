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
          context = env[:context]
          auth_options = context.options[@id]
          username = auth_options[:username]
          password = auth_options[:password]
          value = Base64.encode64([username, password].join(':'))
          value.gsub!("\n", '')
          env[:request_headers][AUTHORIZATION_HEADER] = "Basic #{value}"
          @app.call(env)
        end

      end
    end
  end
end
