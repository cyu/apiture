require 'diesel/auth/base'

module Diesel
  module Auth
    class APIKey < Base
      attr_accessor :nickname, :pass_as, :name

      def self.build(authorization)
        auth = new
        auth.name     = authorization.name
        auth.nickname = authorization.nickname
        auth.pass_as  = authorization.pass_as
        auth
      end

      def activate(api_class)
        header_name = name
        api_class.__send__(:define_method, "#{nickname}=".to_sym) do |header_value|
            (@_auth_http_headers ||= {})[header_name] = header_value
          end
        api_class.send(:include, InstanceMethods)
      end

      def apply_filter(request, context)
        if pass_as.to_sym == :header
          request.headers[name] = context.api.auth_http_headers[name]
        elsif pass_as.to_sym == :query_parameter
          request.add_query_parameter(name, context.api.auth_http_headers[name])
        end
      end

      module InstanceMethods
        def auth_http_headers
          @_auth_http_headers
        end
      end
    end
  end
end
