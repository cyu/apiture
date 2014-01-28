module Diesel
  module Auth
    class HTTPHeader
      def self.activate(api_class, options)
        options.each do |k,v|
          api_class.send(:define_method, "#{k}=".to_sym) do |header_value|
            (@_auth_http_headers ||= {})[v] = header_value
          end
        end
        api_class.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def auth_http_headers
          @_auth_http_headers
        end
      end

      def initialize(api, options)
        @api, @options = api, options
      end

      def set_http_options(context, options)
        if headers = options[:headers]
          headers.merge!(context.api.auth_http_headers)
        else
          options[:headers] = context.api.auth_http_headers.dup
        end
      end
    end
  end
end
