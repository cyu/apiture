module Apiture
  module Middleware
    class SetParameterBase

      def initialize(app, options)
        @app = app
        @name = options[:name]
        @renderer = options[:renderer]
        @default = options[:default]
      end

      def call(env)
        value = find_parameter_value(env)
        if value == nil && @default
          value = @default
        end
        apply_parameter_value(env, value)
        @app.call(env)
      end

      protected

        def find_parameter_value(env)
          if @renderer
            @renderer.render_parameter(@name, env)
          else
            context = env[:context]
            context.get_attribute(@name)
          end
        end

        def apply_parameter_value(env, value)
          raise NotImplementedError
        end
    end
  end
end
