require 'diesel/version'
require 'diesel/json_parser'
require 'diesel/api_builder'
# require 'diesel/dsl'

module Diesel
  def self.parse_json(path)
    Diesel::JSONParser.new.parse_file(path)
  end

  def self.build_api(api_declaration)
    Diesel::APIBuilder.new(api_declaration).build
  end

  def self.load_api(path)
    build_api(parse_json(path))
    # profile = DSL.load_profile(name, "#{name}.rb")
    # Diesel::APIBuilder.new(profile).build
  end
end
