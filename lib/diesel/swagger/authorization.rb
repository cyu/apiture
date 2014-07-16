require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Authorization < Node
      attribute :type
      attribute :pass_as
      attribute :keyname
    end
  end
end
