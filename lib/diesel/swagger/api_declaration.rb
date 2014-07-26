require 'diesel/swagger/node'

module Diesel
  module Swagger
    class APIDeclaration < Node
      attribute :description

      attribute :swagger_version
      attribute :api_version
      attribute :base_path
      attribute :resource_path
      attribute :info, validate: true

      list :apis, validate: true
      list :produces
      list :consumes

      hash :models, validate: true
      hash :authorizations, validate: true
    end
  end
end
