require 'apiture/swagger/node'

module Apiture
  module Swagger
    class ArrayDefinition < Node
      attr_reader :id

      attribute :items

      def initialize(id)
        super()
        @id = id
      end
    end
  end
end

