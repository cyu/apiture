require 'diesel/swagger/node'
require 'diesel/swagger/parameter'

module Diesel
  module Swagger
    class Operation < Node
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
    end
  end
end
