require 'diesel/version'
require 'diesel/swagger/parser'
require 'diesel/api_builder'


module Diesel
  def self.parse_specification(path)
    Diesel::Swagger::Parser.new.parse(File.read(path))
  end

  def self.build_api(specification)
    Diesel::APIBuilder.new(specification).build
  end

  def self.load_api(path)
    build_api(parse_specification(path))
  end
end
