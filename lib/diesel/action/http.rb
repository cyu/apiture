require 'httparty'

module Diesel
  module Action
    class HTTP
      attr_accessor :filters, :request_method

      def filters
        @filters ||= []
      end

      def perform(context)
        req = Request.new(request_method, context.endpoint_url)
        [context.api.class.authenticator].concat(filters).each do |filter|
          filter.apply_filter(req, context)
        end

        if context.logger && context.logger.debug?
          context.logger.debug("Request Method: #{request_method}")
          context.logger.debug("URL: #{context.endpoint_url}")
          context.logger.debug("Options: #{req.http_options.inspect}")
        end

        req.perform
      end

      class Request
        attr_reader :method, :headers, :query
        attr_accessor :url, :body

        def initialize(method, url)
          @method = method
          @url = url
          @headers = {} 
          @query = {}
        end

        def perform
          HTTParty.send(method, url, http_options)
        end

        def http_options
          {headers: headers, query: query, body: body}
        end

        def add_query_parameter(name, value)
          @url = if url.index('?')
            "#{url}&#{URI.escape(name)}=#{URI.escape(value)}"
          else
            "#{url}?#{URI.escape(name)}=#{URI.escape(value)}"
          end
        end
      end

      class ParameterFilter
        attr_reader :parameter

        def initialize(parameter)
          @parameter = parameter
        end

        def apply_filter(request, context)
          v = find_parameter_value(context)
          case parameter.param_type
          when :query
            request.query[parameter.name] = v
          when :path
            request.url = request.url.gsub(path_regex, v.to_s)
          when :body
            request.body = v
          when :header
            request.headers[parameter.name] = v
          end
        end

        def find_parameter_value(context)
          if parameter.complex?
            model = context.api.class.models[parameter.data_type]
            model.build(parameter, context)
          else
            parameter.value || context.get_attribute(parameter.name)
          end
        end

        protected
          def path_regex
            Regexp.new(Regexp.quote("{#{parameter.name}}"))
          end
      end
    end
  end
end
