require 'multi_json'
require 'yaml'
require 'apiture/utils/inflections'
require 'apiture/swagger/specification'


module Apiture
  module Swagger

    class ParseError < Exception; end

    class Parser
      include Apiture::Utils::Inflections

      def parse_json(spec)
        build_specification(MultiJson.load(spec))
      end
      alias :parse :parse_json

      def parse_yaml(spec)
        build_specification(YAML.load(spec))
      end

      def build_specification(json)
        specification = build_node(Specification, json)
        specification.info = build_node(Info, json['info'])
        specification.external_docs = build_node(ExternalDocs, json['externalDocs'])
        specification.schemes = json['schemes']
        specification.produces = json['produces'] || []
        specification.consumes = json['consumes'] || []
        build_security_definition_hash(specification, json)
        build_security_hash(specification, json)
        specification.paths = build_node_hash(Path, json, 'paths') do |path, path_json|
          trace = [path.id]
          [:get, :put, :post, :delete, :options, :head, :patch].each do |method|
            if op_json = path_json[method.to_s]
              trace.unshift(method)
              op = build_node(Operation, op_json, constructor_args: [method], trace: trace)
              op.external_docs = build_node(ExternalDocs, op_json['externalDocs'], trace: trace)
              op.parameters = build_node_list(Parameter, op_json, 'parameters', trace: trace) do |param, param_json|
                trace.unshift(param_json["name"])
                if param_json["schema"] && param_json["schema"].kind_of?(Hash)
                  trace.unshift("schema")
                  schema_json = param_json["schema"]
                  param.schema = build_node(Definition, schema_json, trace: trace)
                  build_schema_content(param.schema, schema_json)
                  trace.shift
                end
                trace.shift
              end
              build_security_definition_hash(op, json)
              build_security_hash(op, op_json)
              path.send("#{method}=".to_sym, op)
              trace.shift
            end
          end
          trace.shift
        end
        specification.definitions = build_node_hash(Definition, json, 'definitions') do |definition, def_json|
          build_schema_content(definition, def_json)
        end
        specification
      end

      protected

        def build_schema_content(definition, def_json)
           definition.properties = build_node_hash(Property, def_json, 'properties') do |prop, prop_json|
            prop.enum = prop_json["enum"]
            prop.items = prop_json["items"]
          end
        end

        def build_security_hash(parent_node, json)
          # leave security nil to defer security to parent. An empty hash means
          # no security.
          if sec_json = json['security']
            parent_node.security = sec_json.reduce({}) do |memo, (k,v)|
              memo[k] = security = Security.new(k)
              security.scopes = v
              memo
            end
          end
        end

        def build_security_definition_hash(parent_node, json)
          if json['securityDefinitions']
            parent_node.security_definitions = build_node_hash(SecurityDefinition, json, 'securityDefinitions')
          end
        end

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
            assert_type json, Hash, "expecting object node", options[:trace]
            json.each_pair do |key, value|
              if key.match(/^x-/)
                extension_name = underscore(key.sub(/^x-/, '')).to_sym
                model.extensions[extension_name] = value
              end
            end
            model
          end
        end

        def build_node_list(model_class, json, json_list_key, options = {})
          trace = options[:trace] || []
          trace.unshift(json_list_key)
          node_list = []
          if json_list = json[json_list_key]
            assert_type json_list, Array, "expecting list", trace
            node_list = json_list.map do |node_json|
              node = build_node(model_class, node_json, trace: trace)
              yield(node, node_json) if block_given?
              node
            end
          end
          trace.unshift
          node_list
        end

        def build_node_hash(model_class, json, json_hash_key)
          (json[json_hash_key] || {}).reduce({}) do |m, (k, v)|
            m[k] = node = build_node(model_class, v, constructor_args: [k])
            yield(node, v) if block_given?
            m
          end
        end

        def assert_type target, expected_type, message, trace
          unless target.kind_of?(expected_type)
            if trace
              message = "[#{trace.reverse.join(" / ")}] - #{message}: #{target.class.name}"
            end
            raise ParseError, message
          end
        end

    end
  end
end
