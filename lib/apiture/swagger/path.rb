require 'apiture/swagger/node'
require 'apiture/swagger/operation'

module Apiture
  module Swagger
    class Path < Node
      attr_reader :id
      alias :path_name :id

      REQUEST_METHODS = [:get, :put, :post, :delete, :options, :head, :patch]

      REQUEST_METHODS.each do |m|
        attribute m, validate: true
      end

      list :parameters, validate: true

      def initialize(id)
        super()
        @id = id
      end

      def operations
        REQUEST_METHODS.map { |m| __send__(m) }.compact
      end

      def operations_map
        REQUEST_METHODS.reduce({}) do |m, method|
          if op = __send__(method)
            m[method] = op
          end
          m
        end
      end
    end
  end
end
