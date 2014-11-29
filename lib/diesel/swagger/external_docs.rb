require 'diesel/swagger/node'

module Diesel
  module Swagger
    class ExternalDocs < Node
      attribute :description
      attribute :url
    end
  end
end
