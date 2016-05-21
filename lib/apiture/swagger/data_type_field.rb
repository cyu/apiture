require 'apiture/swagger/node'

module Apiture
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
      attribute :items

      list :enum
    end
  end
end
