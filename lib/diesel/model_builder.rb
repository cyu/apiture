require 'multi_json'

module Diesel
  class ModelBuilder
    attr_reader :model

    def initialize(model)
      @model = model
    end

    def build(parameter, context)
      h = context.get_attribute(parameter.name)
      unless h
        if parameter.required?
          raise "Missing required parameter #{parameter.name}"
        else
          return nil
        end
      end
      if missing_required_attr = model.required.detect { |r| h[r.to_sym].nil? }
        raise "Missing required value #{missing_required_attr} in #{parameter.name}"
      end
      json = model.properties.reduce({}) do |m, (name, property)|
        name = name.to_sym
        m[name] = h[name] if h[name]; m
      end
      MultiJson.dump(json)
    end
  end
end
