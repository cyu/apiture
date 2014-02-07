module Diesel
  class Endpoint
    attr_reader :path
    attr_accessor :action

    def initialize(path)
      @path = path
    end

    def perform(context)
      raise 'action required for endpoint' unless action

      assert_attributes(context)

      #unless action.accept? context
      #  raise 'endpoint does not support this context'
      #end

      action.perform(context)
    end

    private
      def assert_attributes(context)
        #if attributes.nil?
        #  unless context.attributes.empty?
        #    raise ArgumentError, "invalid attributes #{atts.keys.join(', ')}"
        #  end
        #  return
        #end

        #invalid_atts = context.attributes.keys.map!(&:intern) - attributes.keys
        #unless invalid_atts.empty?
        #  raise ArgumentError, "invalid attributes #{invalid_atts.join(', ')}"
        #end

        #attributes.each do |attr_name, options|
        #  if options[:required] and context.attributes[attr_name].nil?
        #    raise ArgumentError, "require attribute: #{attr_name}"
        #  end
        #end
      end
  end
end
