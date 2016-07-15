require 'apiture/swagger/info'
require 'apiture/swagger/external_docs'
require 'apiture/swagger/security'
require 'apiture/swagger/security_definition'
require 'apiture/swagger/path'
require 'apiture/swagger/definition'
# require 'apiture/swagger/response'

module Apiture
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
      list :security, validate: true

      hash :paths, validate: true
      hash :definitions, validate: true
      hash :parameters, validate: true
      hash :responses, validate: true
      hash :security_definitions, validate: true
    end
  end
end
