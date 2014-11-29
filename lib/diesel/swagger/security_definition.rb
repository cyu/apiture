require 'diesel/swagger/node'

module Diesel
  module Swagger
    class SecurityDefinition < Node
      attribute :type
      attribute :description
      attribute :name
      attribute :in, symbolize: true
      attribute :flow
      attribute :authorization_url
      attribute :token_url
    end
  end
end
