require 'apiture/version'
require 'apiture/api_error'
require 'apiture/utils/inflections'
require 'apiture/api_base'
require 'apiture/data_model'
require 'apiture/uri'

require 'apiture/middleware/debug'
require 'apiture/middleware/set_header'
require 'apiture/middleware/convert_json_body'

module Apiture
  class APIBuilder
    include Apiture::Utils::Inflections

    attr_reader :specification

    def initialize(specification)
      @specification = specification
    end

    def build
      validate!

      create_api_class.tap do |klass|
        klass.api_groups = [
          APIGroup.new.tap do |group|
            group.endpoints = build_endpoints
            group.endpoints.each do |endpoint|
              klass.send(:define_method, endpoint.name.to_sym) do |*args|
                group.execute(self.options, endpoint, *args)
              end
            end
          end
        ]

        #Apiture.const_set create_class_name(name), klass
      end
    end

    protected

      def validate!
        api_errors = specification.collect_errors
        if api_errors.any?
          raise APIError, "API specification is invalid: \n #{api_errors.join("\n")}"
        end
      end

      def create_api_class
        Class.new(Apiture::APIBase)
      end

      def build_endpoint_url(specification, path)
        uri = Apiture::URI.new
        uri.scheme = specification.schemes.first
        uri.host = specification.host
        uri.base_host = specification.extensions[:base_host]
        uri.base_path = specification.base_path.chomp('/')
        uri.resource_path = path.sub(/^([^\/])/, '/\1').chomp('/')
        uri
      end

      def build_endpoints
        spec = specification
        data_models = self.data_models

        spec.paths.map do |path, path_model|
          path_model.operations_map.map do |(method, operation)|
            endpoint_name = underscore(operation.operation_id)
            endpoint_url  = build_endpoint_url(spec, path)

            Apiture::Endpoint.new(endpoint_name, endpoint_url, method).tap do |endpoint|
              endpoint.config_middleware do
                consumes =
                    (operation.consumes && operation.consumes.first) ||
                    (spec.consumes && spec.consumes.first) 

                produces =
                    (operation.produces && operation.produces.first) ||
                    (spec.produces && spec.produces.first) 

                security = operation.security || spec.security

                use Apiture::Middleware::Debug
                use Apiture::Middleware::SetHeader, 'User-Agent' => "apiture-rb/#{Apiture::VERSION}"

                if consumes
                  use Apiture::Middleware::SetHeader, 'Content-Type' => consumes
                end

                if produces
                  use Apiture::Middleware::SetHeader, 'Accept' => produces
                end

                security_ids = if security
                                 security.keys
                               else
                                 if operation.security_definitions && !operation.security_definitions.empty?
                                   [operation.security_definitions.keys.first]
                                 elsif spec.security_definitions && !spec.security_definitions.empty?
                                   [spec.security_definitions.keys.first]
                                 else
                                   []
                                 end
                               end

                unless security_ids.empty?
                  security_defs = spec.security_definitions || {}
                  if operation.security_definitions
                    security_defs = security_defs.merge(operation.security_definitions)
                  end

                  security_ids.each do |name|
                    security_def = security_defs[name]

                    if security_def.nil?
                      raise APIError, "Missing security definition: #{name}, operation=#{endpoint_name}, method=#{method}"
                    end

                    case security_def.type
                    when 'apiKey'
                      require 'apiture/middleware/auth/api_key'
                      use Apiture::Middleware::Auth::APIKey,
                          id: Apiture::Utils::Inflections.underscore(name).to_sym,
                          in: security_def.in,
                          name: security_def.name,
                          format: security_def.extensions[:format]
                    when 'oauth2'
                      require 'apiture/middleware/auth/oauth2'
                      use Apiture::Middleware::Auth::OAuth2,
                          id: Apiture::Utils::Inflections.underscore(name).to_sym,
                          in: security_def.in,
                          name: security_def.name
                    when "basic"
                      require "apiture/middleware/auth/basic"
                      use Apiture::Middleware::Auth::Basic,
                          id: Apiture::Utils::Inflections.underscore(name).to_sym
                    else
                      raise APIError, "Unsupported security definition: #{security_def.type}"
                    end
                  end
                end

                operation.parameters.each do |parameter|
                  param_class_path = "apiture/middleware/set_#{parameter.in}_parameter"
                  param_class_name = Apiture::Utils::Inflections.camelize(param_class_path)
                  require param_class_path unless Object::const_defined?(param_class_name)
                  param_class = Apiture::Utils::Inflections.constantize(param_class_name)
                  middleware_opts = {name: parameter.name}
                  if parameter.schema?
                    schema = parameter.schema
                    if schema.kind_of? String
                      schema = data_models[parameter.schema]
                    else
                      schema = DataModel.new(schema)
                    end
                    unless schema
                      raise APIError, "Unspecified schema: #{parameter.schema}; parameter=#{parameter.name}"
                    end
                    middleware_opts[:schema] = schema
                  end
                  if spec.extensions[:version_parameter] && spec.extensions[:version_parameter]["name"] == parameter.name
                    middleware_opts[:default] = spec.extensions[:version_parameter]["version"]
                  end
                  use param_class, middleware_opts
                end

                if consumes == "application/json" || (operation.parameters && operation.parameters.detect { |p| p.in == :body })
                  use Apiture::Middleware::ConvertJSONBody
                end
              end
            end
          end
        end.flatten.compact
      end

      def data_models
        @data_models ||= build_data_models
      end

      def build_data_models
        specification.definitions.reduce({}) do |m, (name, definition)|
          m[name] = DataModel.new(definition)
          m
        end
      end

      def create_class_name(name)
        string = name.to_s.sub(/.*\./, '')
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
      end

  end
end
