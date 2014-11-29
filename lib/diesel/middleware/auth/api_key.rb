module Diesel
  module Middleware
    module Auth
      class APIKey

        def initialize(app, options)
          @app = app
          @id = options[:id]
          @in = options[:in]
          @name = options[:name]
        end

        def call(env)
          context = env[:context]
          value = context.options[@id]
          if @in == :header
            env[:request_headers][@name] = value
          elsif pass_as == :query
            env[:params][@name] = value
          end
          @app.call(env)
        end

      end
    end
  end
end
