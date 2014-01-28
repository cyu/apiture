module Diesel
  module Profile
    class Endpoint
      attr_accessor :name, :path, :attributes, :action

      def initialize(name, path)
        @name, @path = name.to_sym, path
      end

      def attributes
        (@attributes ||= [])
      end

      def define_endpoint(klass)
        _endpoint = Diesel::Endpoint.new(path)
        action.define_action(_endpoint)
        attributes.each { |att| att.define_attribute(_endpoint) }
        klass.send(:define_method, name) do |attributes|
          RequestContext.new(self, _endpoint, attributes).perform
        end
      end
    end
  end
end
