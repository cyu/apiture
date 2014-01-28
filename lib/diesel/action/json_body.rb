require 'diesel/action/base'
require 'httparty'
require 'multi_json'

module Diesel
  module Action
    class JSONBody < Base
      attr_accessor :request_method, :values

      def initialize(request_method, values)
        @request_method, @values = request_method, values
      end

      def perform(context)
        options = context.http_options
        options[:body] = build_json_body(context)
        if context.logger && context.logger.debug?
          context.logger.debug("Request Method: #{request_method}")
          context.logger.debug("URL: #{context.endpoint_url}")
          context.logger.debug("Options: #{options.inspect}")
        end 
        HTTParty.send(request_method, context.endpoint_url, options)
      end

      protected
        def build_json_body(context)
          MultiJson.dump(@values.reduce(Hash.new) do |m, value_name|
            if v = context.get_attribute(value_name)
              m[value_name] = v
            end
            m
          end) + "\n"
        end
    end
  end
end
