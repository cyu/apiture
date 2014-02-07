require 'multi_json'
require 'diesel/model_builder'

module Diesel
  class ComplexTypeBuilder < ModelBuilder
    def build(parameter, context)
      h = context.get_attribute(parameter.name)
      unless h
        if parameter.required?
          raise "Missing required parameter #{parameter.name}"
        else
          return nil
        end
      end
      if model.required.detect { |r| h[r].nil? }
        raise "Missing required value #{r} in #{parameter.name}"
      end
      json = model.properties.reduce({}) do |m, property|
        m[property.name] = h[property.name] if h[property.name]; m
      end
      MultiJson.dump(json)
    end
  end
end
