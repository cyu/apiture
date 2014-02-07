require 'diesel/action/http'
require 'diesel/complex_type_builder'
require 'diesel/container_builder'

module Diesel
  class APIBuilder
    attr_reader :profile

    def initialize(profile)
      @profile = profile
    end

    def build
      create_api_class.tap do |klass|
        klass.base_path = profile.base_path
        unless profile.authorizations.empty?
          klass.authenticator = Diesel::Authenticator.build(profile.authorizations)
        end
        build_endpoints(klass)
        build_models(klass)
        #Diesel.const_set create_class_name(name), klass
      end
    end

    protected
      def global_filters
        @global_filters ||= profile.parameters.map { |p| Diesel::Action::HTTP::ParameterFilter.new(p) }
      end

      def create_api_class
        Class.new(Diesel::API)
      end

      def build_endpoints(klass)
        klass.endpoints = profile.resources.map do |resource|
          resource.operations.map do |operation|
            Diesel::Endpoint.new(resource.path).tap do |endpoint|
              action = Diesel::Action::HTTP.new
              action.request_method = operation.method
              action.filters.concat(global_filters)
              action.filters.concat(operation.parameters.map { |p| Diesel::Action::HTTP::ParameterFilter.new(p) })
              endpoint.action = action
              klass.__send__(:define_method, operation.nickname) do |parameters|
                execute(endpoint, parameters)
              end
            end
          end
        end.flatten.compact
      end

      def build_models(klass)
        klass.models = profile.models.map do |model|
          if model.is_a? Diesel::Profile::Container
            Diesel::ContainerBuilder.new(model)
          else
            Diesel::ComplexTypeBuilder.new(model)
          end
        end.reduce({}) { |m,b| m[b.model.name] = b; m }
      end

      def create_class_name(name)
        string = name.to_s.sub(/.*\./, '')
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
      end

  end
end
