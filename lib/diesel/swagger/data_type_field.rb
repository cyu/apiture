require 'diesel/swagger/node'

module Diesel
  module Swagger
    class DataTypeField < Node
      attribute :type, symbolize: true
      attribute :format
      attribute :default_value
      attribute :multiple_of
      attribute :maximum
      attribute :exclusive_maximum, type: :boolean
      attribute :minimum
      attribute :exclusive_minimum, type: :boolean
      attribute :max_length
      attribute :min_length
      attribute :pattern
      attribute :max_items
      attribute :min_items
      attribute :unique_items, type: :boolean

      list :enum
      list :items
    end
  end
end
