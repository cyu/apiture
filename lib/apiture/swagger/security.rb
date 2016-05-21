require 'apiture/swagger/node'

module Apiture
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
