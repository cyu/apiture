require 'diesel/dsl'

module Diesel
  def self.load_api(name)
    profile = DSL.load_profile(name, "#{name}.rb")
    profile.api_class
  end
end
