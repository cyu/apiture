require 'diesel/swagger/data_type_field'

module Diesel
  module Swagger
    class Property < DataTypeField
      attr_reader :id

      def initialize(id)
        super()
        @id = id
      end

    end
  end
end
