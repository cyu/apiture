require 'multi_json'

module Apiture
  class DataModel
    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

    def build(parameter_name, env)
      context = env[:context]
      h = context.get_attribute(parameter_name)
      return nil unless h

      json = definition.properties.reduce({}) do |m, (name, property)|
        name = name.to_sym
        m[name] = h[name] if h[name]; m
      end

      json
    end
  end
end
