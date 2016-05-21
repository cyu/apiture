require 'apiture/swagger/node'

module Apiture
  module Swagger
    class SecurityDefinition < Node
      attr_reader :id

      attribute :type
      attribute :description
      attribute :name
      attribute :in, symbolize: true
      attribute :flow
      attribute :authorization_url
      attribute :token_url
      attribute :scopes

      def initialize(id)
        super()
        @id = id
      end
    end
  end
end
