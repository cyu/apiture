require 'multi_json'
require 'diesel/inflections'
require 'diesel/swagger/api_declaration'
require 'diesel/swagger/authorization'
require 'diesel/swagger/api'
require 'diesel/swagger/operation'
require 'diesel/swagger/parameter'
require 'diesel/swagger/model'
require 'diesel/swagger/property'
require 'diesel/swagger/info'

module Diesel
  class JSONParser
    include Inflections

    def parse_file(fn)
      json = File.new(fn, 'r')
      load_declaration(MultiJson.load(json))
    end

    def parse(json)
      load_declaration(MultiJson.load(json))
    end

    def load_declaration(json)
      declaration = build_node(Diesel::Swagger::APIDeclaration, json)
      declaration.info = build_node(Diesel::Swagger::Info, json['info'])
      declaration.authorizations = build_node_hash(Diesel::Swagger::Authorization, json, 'authorizations')
      declaration.produces = json['produces'] || []
      declaration.apis = build_node_list(Diesel::Swagger::API, json, 'apis') do |api, api_json|
        api.operations = build_node_list(Diesel::Swagger::Operation, api_json, 'operations') do |op, op_json|
          op.parameters = build_node_list(Diesel::Swagger::Parameter, op_json, 'parameters')
        end
      end
      declaration.models = build_node_hash(Diesel::Swagger::Model, json, 'models') do |model, model_json|
        model.properties = build_node_hash(Diesel::Swagger::Property, model_json, 'properties')
      end
      declaration
    end

    protected

    def build_node(model_class, json)
      model = model_class.new
      model_class.attribute_names.each do |att|
        model.send("#{att}=".to_sym, json[camelize(att.to_s)])
      end
      model
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
