module Diesel
  class ModelBuilder
    attr_reader :model

    def initialize(model)
      @model = model
    end
  end
end
