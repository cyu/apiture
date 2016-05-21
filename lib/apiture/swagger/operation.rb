require 'apiture/swagger/node'
require 'apiture/swagger/parameter'

module Apiture
  module Swagger
    class Operation < Node
      attr_reader :id
      alias :method_name :id

      attribute :summary
      attribute :description
      attribute :external_docs, validate: true
      attribute :operation_id
      attribute :deprecated

      list :tags
      list :consumes
      list :produces
      list :parameters, validate: true
      list :responses, validate: true
      list :schemes

      hash :security_definitions, validate: true
      hash :security, validate: true

      def initialize(id)
        super()
        @id = id
      end
    end
  end
end
