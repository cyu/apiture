require 'diesel/middleware/set_parameter_base'

module Diesel
  module Middleware
    class SetBodyParameter < SetParameterBase
      def apply_parameter_value(env, value)
        env[:body] = value
      end
    end
  end
end
