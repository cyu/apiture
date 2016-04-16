require 'apiture/swagger/data_type_field'

module Apiture
  module Swagger
    class Parameter < DataTypeField
      VALID_TYPES = %w(
        string
        number
        integer
        boolean
        array
        file
      )

      attribute :name
      attribute :in, symbolize: true
      attribute :description
      attribute :required, type: :boolean
      attribute :schema

      def schema?
        !!schema
      end

      def validate
        if self.in.nil?
          errors << "in attribute is required"
        end
        if self.in == :path && !required?
          errors << "Path parameters must be defined as required"
        end
      end
    end
  end
end
