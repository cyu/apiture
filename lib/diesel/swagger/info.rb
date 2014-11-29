require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Info < Node
      attribute :title
      attribute :description
      attribute :terms_of_service
      attribute :contact
      attribute :license
      attribute :version
    end
  end
end
