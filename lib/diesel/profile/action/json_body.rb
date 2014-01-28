require 'diesel/action/json_body'

module Diesel
  module Profile
    module Action
      class JSONBody
        attr_accessor :request_method, :values

        def initialize(request_method = :post)
          @request_method = request_method
          @values = []
        end

        def define_action(endpoint)
          endpoint.action = Diesel::Action::JSONBody.new(request_method, values)
        end
      end
    end
  end
end
