module Apiture
  module Swagger
    class DefinitionReference < Node

      attr_reader :ref

      def initialize(ref)
        @ref = ref
      end

      def definitionId
        @ref.split('/').last
      end
    end
  end
end
