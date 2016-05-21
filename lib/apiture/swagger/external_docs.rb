require 'apiture/swagger/node'

module Apiture
  module Swagger
    class ExternalDocs < Node
      attribute :description
      attribute :url
    end
  end
end
