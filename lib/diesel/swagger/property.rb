require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Property < Node
      attribute :type
      attribute :enum
    end
  end
end
