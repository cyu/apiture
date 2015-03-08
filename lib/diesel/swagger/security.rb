require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Security < Node
      attr_reader :id

      attribute :scopes

      def initialize(id)
        super()
        @id = id
      end

      def serializable_hash
        scopes || []
      end

    end
  end
end
