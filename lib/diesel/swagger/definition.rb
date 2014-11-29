require 'diesel/swagger/node'
require 'diesel/swagger/property'

module Diesel
  module Swagger
    class Definition < Node
      attribute :required
      attribute :discriminator
      hash :properties
    end
  end
end
