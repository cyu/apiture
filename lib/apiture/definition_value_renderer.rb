module Apiture

  class DefinitionValueRenderer

    def initialize(definition, all_definitions)
      @definition = definition
      @all_definitions = all_definitions
    end

    def render_parameter(parameter_name, env)
      context = env[:context]
      h = context.get_attribute(parameter_name)
      return nil unless h
      render(h)
    end

    def render(data)
      if @definition.kind_of? Swagger::ObjectDefinition
        render_object_def(data)
      elsif @definition.kind_of? Swagger::ArrayDefinition
        render_array_def(data)
      else
        raise Apiture::APIError, "Unsupported definition: #{@definition}"
      end
    end

    def render_object_def(hash)
      @definition.properties.reduce({}) do |memo, (name, _)|
        name = name.to_sym
        if hash[name]
          memo[name] = hash[name]
        end
        memo
      end
    end

    def render_array_def(array)
      array.dup
    end

  end
end
