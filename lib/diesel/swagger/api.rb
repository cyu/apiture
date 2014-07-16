require 'diesel/swagger/node'

module Diesel
  module Swagger
    class API < Node
      attribute :path
      attribute :description
      list :operations, validate: true
    end
  end
end
