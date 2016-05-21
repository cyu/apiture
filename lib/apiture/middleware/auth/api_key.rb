module Apiture
  module Middleware
    module Auth
      class APIKey

        def initialize(app, options)
          @app = app
          @id = options[:id]
          @in = options[:in]
          @name = options[:name]
          @format = options[:format]
        end

        def call(env)
          context = env[:context]
          value = format_value(context.options[@id])
          if @in == :header
            env[:request_headers][@name] = value
          elsif @in == :query
            env[:params][@name] = value
          elsif @in == :body
            env[:body] = if body = env[:body]
              body.merge(@name => value)
            else
              { @name => value }
            end
          end
          @app.call(env)
        end

        protected
          def format_value(val)
            return val unless @format
            @format % val
          end
      end
    end
  end
end
