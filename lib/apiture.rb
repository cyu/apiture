require 'apiture/version'
require 'apiture/swagger/parser'
require 'apiture/api_builder'


module Apiture

  def self.parse_specification(path)
    if path.match(/\.yml$/)
      Apiture::Swagger::Parser.new.parse_yaml(File.read(path))
    else
      Apiture::Swagger::Parser.new.parse_json(File.read(path))
    end
  end

  def self.build_api(specification)
    Apiture::APIBuilder.new(specification).build
  end

  def self.load_api(path)
    build_api(parse_specification(path))
  end

end
