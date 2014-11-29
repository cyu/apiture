require 'diesel/middleware/set_parameter_base'

module Diesel
  module Middleware
    class SetPathParameter < SetParameterBase

      def initialize(app, options)
        super
        @regex = Regexp.new(Regexp.quote("{#{@name}}"))
      end

      def apply_parameter_value(env, value)
        env[:url] = env[:url].gsub(@regex, value.to_s)
      end
    end
  end
end
