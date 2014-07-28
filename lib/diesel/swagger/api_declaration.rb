require 'diesel/swagger/node'

module Diesel
  module Swagger
    class APIDeclaration < Node
      attribute :description

      attribute :swagger_version
      attribute :api_version
      attribute :base_path
      attribute :resource_path

      list :apis, validate: true
      list :produces
      list :consumes

      hash :models, validate: true
      hash :authorizations, validate: true

      # non-standard attributes
      attribute :info, validate: true
    end
  end
end
