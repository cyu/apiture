require 'diesel/version'
require 'diesel/swagger/parser'
require 'diesel/api_builder'


module Diesel
  def self.parse_specification(path)
    if path.match(/\.yml$/)
      Diesel::Swagger::Parser.new.parse_yaml(File.read(path))
    else
      Diesel::Swagger::Parser.new.parse_json(File.read(path))
    end
  end

  def self.build_api(specification)
    Diesel::APIBuilder.new(specification).build
  end

  def self.load_api(path)
    build_api(parse_specification(path))
  end
end
