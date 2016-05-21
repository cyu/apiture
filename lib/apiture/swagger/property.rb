require 'apiture/swagger/data_type_field'

module Apiture
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
