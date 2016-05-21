require 'apiture/middleware/set_parameter_base'

module Apiture
  module Middleware
    class SetBodyParameter < SetParameterBase
      def apply_parameter_value(env, value)
        if value
          env[:body] = if body = env[:body]
            body.merge(value)
          else
            value
          end
          if env[:request_headers]["Content-Type"].nil?
            env[:request_headers]["Content-Type"] = "application/json"
          end
        end
      end
    end
  end
end
