require 'diesel/profile/base'
require 'diesel/api'
require 'diesel/authenticator'

module Diesel
  module Profile
    class API < Base
      attr_reader :name

      attr_accessor :base_uri
      attr_accessor :auth_type
      attr_accessor :auth_options
      attr_accessor :endpoints
      attr_accessor :request_headers
      attr_accessor :attributes

      def initialize(name)
        @name = name
      end

      def attributes
        @attributes ||= []
      end

      def endpoints
        @endpoints ||= []
      end

      def api_class
        @api_class ||= create_api_class.tap do |klass|
          klass.base_uri = base_uri
          unless auth_type.nil?
            klass.authenticator = Diesel::Authenticator.create(auth_type, auth_options)
          end
          define_request_headers(klass)
          create_endpoints(klass)
          Diesel.const_set create_class_name(name), klass
        end
      end

      protected
        def define_request_headers(klass)
          class << klass
            def request_headers
              @_request_headers ||= {}
            end
          end
          klass.request_headers.merge!(request_headers)
        end

        def create_endpoints(klass)
          endpoints.each { |ep| ep.define_endpoint(klass) }
        end

        def create_api_class
          Class.new(Diesel::API)
        end

        def create_class_name(name)
          string = name.to_s.sub(/.*\./, '')
          string = string.sub(/^[a-z\d]*/) { $&.capitalize }
          string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
        end
    end
  end
end
