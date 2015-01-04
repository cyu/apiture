require 'diesel/middleware/set_parameter_base'

module Diesel
  module Middleware
    class SetQueryParameter < SetParameterBase
      def apply_parameter_value(env, value)
        unless value.nil?
          env[:params][@name] = value
        end
      end
    end
  end
end
