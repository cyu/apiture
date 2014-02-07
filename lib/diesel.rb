require 'diesel/dsl'
require 'diesel/api_builder'

module Diesel
  def self.load_api(name)
    profile = DSL.load_profile(name, "#{name}.rb")
    Diesel::APIBuilder.new(profile).build
  end
end
