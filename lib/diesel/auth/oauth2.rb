module Diesel
  module Auth
    class OAuth2
      def self.activate(api_class, options)
        api_class.send :attr_accessor, :access_token
      end

      def self.append_authentication(context, http_options)
        (http_options[:headers] ||= {})['Authorization'] = "Bearer #{context.api.access_token}"
      end
    end
  end
end
