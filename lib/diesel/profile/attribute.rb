module Diesel
  module Profile
    class Attribute
      attr_accessor :name, :options

      def initialize(name, options = {})
        @name = name.to_sym
        @options = options
      end

      def define_attribute(target)
        target.attributes[name] = options
      end
    end
  end
end
