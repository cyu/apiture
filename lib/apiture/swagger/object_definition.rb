require 'apiture/swagger/node'
require 'apiture/swagger/property'

module Apiture
  module Swagger
    class ObjectDefinition < Node
      attr_reader :id

      attribute :required
      attribute :discriminator

      hash :items
      hash :properties

      def initialize(id = "<Inline>")
        super()
        @id = id
      end
    end
  end
end
