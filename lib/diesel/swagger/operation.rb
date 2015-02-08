require 'diesel/swagger/node'
require 'diesel/swagger/parameter'

module Diesel
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
      list :security, validate: true

      def initialize(id)
        super()
        @id = id
      end
    end
  end
end
