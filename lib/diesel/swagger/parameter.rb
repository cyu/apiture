require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Parameter < Node
      PRIMITIVE_TYPES = %w(
        integer
        string
        number
        boolean
      )

      attribute :param_type, symbolize: true
      attribute :name
      attribute :required, type: :boolean
      attribute :type
      attribute :format

      def primitive?
        PRIMITIVE_TYPES.include?(type)
      end

      def array?
        type == 'array'
      end

      def model?
        !primitive? && !array?
      end

      def validate
        errors << "Type is required for parameter '#{name}'" if type.nil?

        if param_type == :body && name != "body"
          errors << "Body parameter must have the name of 'body'"
        end

        if param_type == :path && !required?
          errors << "Path parameters must be defined as required"
        end
      end
    end
  end
end
