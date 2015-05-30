require 'multi_json'
require 'diesel/utils/inflections'
require 'diesel/swagger/specification'


module Diesel
  module Swagger
    class Parser
      include Diesel::Utils::Inflections

      def parse(spec)
        build_specification(MultiJson.load(spec))
      end

      def build_specification(json)
        specification = build_node(Specification, json)
        specification.info = build_node(Info, json['info'])
        specification.external_docs = build_node(ExternalDocs, json['externalDocs'])
        specification.schemes = json['schemes']
        specification.produces = json['produces'] || []
        specification.security_definitions = build_node_hash(SecurityDefinition, json, 'securityDefinitions')
        specification.security = (json['security'] || {}).reduce({}) do |memo, (k,v)|
          memo[k] = security = Security.new(k)
          security.scopes = v
          memo
        end
        specification.paths = build_node_hash(Path, json, 'paths') do |path, path_json|
          [:get, :put, :post, :delete, :options, :head, :patch].each do |method|
            if op_json = path_json[method.to_s]
              op = build_node(Operation, op_json, constructor_args: [method])
              op.external_docs = build_node(ExternalDocs, op_json['externalDocs'])
              op.parameters = build_node_list(Parameter, op_json, 'parameters')
              path.send("#{method}=".to_sym, op)
            end
          end
        end
        specification.definitions = build_node_hash(Definition, json, 'definitions') do |definition, def_json|
          definition.properties = build_node_hash(Property, def_json, 'properties') do |prop, prop_json|
            prop.enum = prop_json['enum']
            prop.items = prop_json['items']
          end
        end
        specification
      end

      protected

        def build_node(model_class, json, options = {})
          if json
            model = if constructor_args = options[:constructor_args]
              model_class.new(*constructor_args)
            else
              model_class.new
            end
            model_class.attribute_names.each do |att|
              model.send("#{att}=".to_sym, json[camelize(att.to_s, false)])
            end
            json.each_pair do |key, value|
              if key.match(/^x-/)
                extension_name = underscore(key.sub(/^x-/, '')).to_sym
                model.extensions[extension_name] = value
              end
            end
            model
          end
        end

        def build_node_list(model_class, json, json_list_key)
          (json[json_list_key] || []).map do |node_json|
            node = build_node(model_class, node_json)
            yield(node, node_json) if block_given?
            node
          end
        end

        def build_node_hash(model_class, json, json_hash_key)
          (json[json_hash_key] || {}).reduce({}) do |m, (k, v)|
            m[k] = node = build_node(model_class, v, constructor_args: [k])
            yield(node, v) if block_given?
            m
          end
        end

    end
  end
end
