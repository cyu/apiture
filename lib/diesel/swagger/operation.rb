require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Operation < Node
      attribute :method
      attribute :summary
      attribute :notes
      attribute :nickname

      list :parameters, validate: true
    end
  end
end
