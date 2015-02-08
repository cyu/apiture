require 'diesel/swagger/node'
require 'diesel/swagger/property'

module Diesel
  module Swagger
    class Definition < Node
      attr_reader :id

      attribute :required
      attribute :discriminator

      hash :properties

      def initialize(id)
        super()
        @id = id
      end
    end
  end
end
