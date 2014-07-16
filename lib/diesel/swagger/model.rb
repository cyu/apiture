require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Model < Node
      attribute :id
      attribute :description
      attribute :required
      hash :properties
    end
  end
end
