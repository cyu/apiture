require 'diesel/swagger/info'
require 'diesel/swagger/external_docs'
require 'diesel/swagger/security_definition'
require 'diesel/swagger/path'
require 'diesel/swagger/definition'
# require 'diesel/swagger/response'

module Diesel
  module Swagger
    class Specification < Node
      attribute :swagger
      attribute :info, validate: true
      attribute :host
      attribute :base_path
      attribute :external_docs, validate: true

      list :schemes
      list :consumes
      list :produces
      list :tags, validate: true

      hash :paths, validate: true
      hash :definitions, validate: true
      hash :parameters, validate: true
      hash :responses, validate: true
      hash :security_definitions, validate: true
      hash :security
    end
  end
end
