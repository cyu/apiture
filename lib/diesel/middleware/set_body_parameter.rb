require 'diesel/middleware/set_parameter_base'

module Diesel
  module Middleware
    class SetBodyParameter < SetParameterBase
      def apply_parameter_value(env, value)
        if value
          env[:body] = if body = env[:body]
            body.merge(value)
          else
            value
          end
        end
      end
    end
  end
end
