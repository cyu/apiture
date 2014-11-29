require 'diesel/api_error'
require 'diesel/utils/inflections'
require 'diesel/api_base'
require 'diesel/data_model'

require 'diesel/middleware/debug'
require 'diesel/middleware/set_header'

module Diesel
  class APIBuilder
    include Diesel::Utils::Inflections

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
              klass.send(:define_method, endpoint.name.to_sym) do |parameters|
                group.execute(self.options, endpoint, parameters)
              end
            end
          end
        ]

        #Diesel.const_set create_class_name(name), klass
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
        Class.new(Diesel::APIBase)
      end

      def build_endpoint_url(specification, path)
        base_path     = specification.base_path.chomp('/')
        resource_path = path.sub(/^([^\/])/, '/\1').chomp('/')
        [
          specification.schemes.first,
          '://',
          specification.host,
          base_path,
          resource_path
        ].join('')
      end

      def build_endpoints
        spec = specification
        data_models = self.data_models

        spec.paths.map do |path, path_model|
          path_model.operations_map.map do |(method, operation)|
            endpoint_name = underscore(operation.operation_id)
            endpoint_url  = build_endpoint_url(spec, path)

            Diesel::Endpoint.new(endpoint_name, endpoint_url, method).tap do |endpoint|
              endpoint.config_middleware do
                use Diesel::Middleware::Debug

                if spec.produces.any?
                  use Diesel::Middleware::SetHeader, 'Content-Type' => spec.produces.first
                end

                spec.security_definitions.each_pair do |name, security_def|
                  case security_def.type
                  when 'apiKey'
                    require 'diesel/middleware/auth/api_key'
                    use Diesel::Middleware::Auth::APIKey,
                        id: Diesel::Utils::Inflections.underscore(name).to_sym,
                        in: security_def.in,
                        name: security_def.name
                  else
                    raise APIError, "Unsupported security definition: #{security_def.type}"
                  end
                end

                operation.parameters.each do |parameter|
                  param_class_path = "diesel/middleware/set_#{parameter.in}_parameter"
                  require param_class_path
                  param_class_name = Diesel::Utils::Inflections.camelize(param_class_path)
                  param_class = Diesel::Utils::Inflections.constantize(param_class_name)
                  middleware_opts = {name: parameter.name}
                  if parameter.schema?
                    unless schema = data_models[parameter.schema]
                      raise APIError, "Unspecified schema: #{parameter.schema}"
                    end
                    middleware_opts[:schema] = schema
                  end
                  use param_class, middleware_opts
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
