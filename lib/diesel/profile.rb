require 'diesel/api'
require 'diesel/authenticator'

module Diesel
  module Profile
    class Base
      attr_accessor :description
    end

    class Authorization < Base
      attr_accessor :name, :nickname, :pass_as, :type
    end

    class Property < Base
      attr_accessor :name, :enum
    end

    class Model < Base
      attr_accessor :name
    end

    class ComplexType < Model
      attr_accessor :required, :properties

      def required
        @required ||= []
      end

      def properties 
        @properties ||= []
      end
    end

    class Container < Model
      attr_accessor :type
    end

    class Parameter < Base
      PRIMITIVE_TYPES = [
        :integer,
        :long,
        :float,
        :double,
        :string,
        :byte,
        :boolean,
        :date,
        :date_time
      ]

      attr_accessor :param_type, :name, :value, :data_type, :required

      def complex?
        !data_type.nil? && !primitive?
      end

      def primitive?
        PRIMITIVE_TYPES.include?(data_type)
      end

      def required?
        !!required
      end
    end

    class Operation < Base
      attr_accessor :nickname, :reference_url, :method, :parameters

      def parameters
        @parameters ||= []
      end
    end

    class Resource < Base
      attr_accessor :path, :operations

      def initialize(path)
        @path = path
      end

      def operations
        @operations ||= []
      end
    end

    class API < Base
      attr_reader :name
      attr_accessor :api_version, :base_path, :auth_type, :auth_options, :resources, :parameters, :authorizations

      def initialize(name)
        @name = name
      end

      def parameters 
        @parameters ||= []
      end

      def resources
        @resources ||= []
      end

      def models
        @models ||= []
      end

      def authorizations
        @authorizations ||= []
      end
    end

  end
end
