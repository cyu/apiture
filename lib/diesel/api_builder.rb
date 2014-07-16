require 'diesel/api'
require 'diesel/authenticator'
require 'diesel/endpoint'
require 'diesel/action/http'
require 'diesel/model_builder'
require 'diesel/inflections'

module Diesel
  class APIBuilder
    include Inflections

    attr_reader :api_declaration

    def initialize(api_declaration)
      @api_declaration = api_declaration
    end

    def build
      if (api_errors = api_declaration.collect_errors).any?
        raise APIError, "API declaration is invalid: \n #{api_errors.join("\n")}"
      end

      create_api_class.tap do |klass|
        klass.base_path = api_declaration.base_path
        unless api_declaration.authorizations.empty?
          klass.authenticator = Diesel::Authenticator.build(api_declaration.authorizations)
        end
        build_endpoints(klass)
        build_models(klass)
        #Diesel.const_set create_class_name(name), klass
      end
    end

    protected
      def global_filters
        @global_filters ||= []
      end

      def create_api_class
        Class.new(Diesel::API)
      end

      def build_endpoints(klass)
        klass.endpoints = api_declaration.apis.map do |api|
          api.operations.map do |operation|
            Diesel::Endpoint.new(api.path).tap do |endpoint|
              action = Diesel::Action::HTTP.new
              if api_declaration.produces.any?
                action.content_type = api_declaration.produces.first
              end
              action.request_method = operation.method
              action.filters.concat(global_filters)
              action.filters.concat(operation.parameters.map { |p| Diesel::Action::HTTP::ParameterFilter.new(p) })
              endpoint.action = action
              klass.__send__(:define_method, underscore(operation.nickname)) do |parameters|
                execute(endpoint, parameters)
              end
            end
          end
        end.flatten.compact
      end

      def build_models(klass)
        klass.models = api_declaration.models.reduce({}) do |memo, (name, model)|
          memo[name] = Diesel::ModelBuilder.new(model)
          memo
        end
      end

      def create_class_name(name)
        string = name.to_s.sub(/.*\./, '')
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
      end

  end
end
