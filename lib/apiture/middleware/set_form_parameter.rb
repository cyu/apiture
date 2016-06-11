require 'apiture/middleware/set_parameter_base'

module Apiture
  module Middleware
    class SetFormParameter < SetParameterBase
      def apply_parameter_value(env, value)
        unless value.nil?
          env[:params][@name] = value
        end
      end
    end
  end
end

