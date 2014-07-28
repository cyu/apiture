require 'diesel/swagger/node'

module Diesel
  module Swagger
    class Info < Node

      attribute :title
      attribute :description
      attribute :terms_of_service_url
      attribute :contact
      attribute :license
      attribute :license_url

      # non-standard attributes
      attribute :url
    end
  end
end
