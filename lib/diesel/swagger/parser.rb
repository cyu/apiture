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
        specification.security_definitions = build_node_hash(Swagger::SecurityDefinition, json, 'securityDefinitions')
        specification.paths = build_node_hash(Path, json, 'paths') do |path, path_json|
          [:get, :put, :post, :delete, :options, :head, :patch].each do |method|
            if op_json = path_json[method.to_s]
              op = build_node(Operation, op_json)
              op.external_docs = build_node(ExternalDocs, op_json['externalDocs'])
              op.parameters = build_node_list(Parameter, op_json, 'parameters')
              path.send("#{method}=".to_sym, op)
            end
          end
        end
        specification.definitions = build_node_hash(Swagger::Definition, json, 'definitions') do |definition, def_json|
          definition.properties = build_node_hash(Swagger::Property, def_json, 'properties') do |prop, prop_json|
            prop.enum = prop_json['enum']
            if prop_json['items']
              prop.items = [prop_json['items']].flatten.map do |item_json|
                build_node(Swagger::ItemType, item_json).tap do |item_type|
                  if ref = item_json['$ref']
                    item_type.ref = ref
                  end
                end
              end
            end
          end
        end
        specification
      end

      protected

        def build_node(model_class, json)
          if json
            model = model_class.new
            model_class.attribute_names.each do |att|
              model.send("#{att}=".to_sym, json[camelize(att.to_s, false)])
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
            m[k] = node = build_node(model_class, v)
            yield(node, v) if block_given?
            m
          end
        end

    end
  end
end
