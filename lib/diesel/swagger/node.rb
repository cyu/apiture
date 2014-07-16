module Diesel
  module Swagger
    class Node
      class << self
        def attribute_names
          @attribute_names || []
        end

        def list_names
          @list_names || []
        end

        def hash_names
          @hash_names || []
        end

        def attribute(name, options = {})
          name = name.to_sym
          (@attribute_names ||= []) << name
          attr_accessor name
          if options[:type] == :boolean
            define_method("#{name}?".to_sym) do
              !!send(name)
            end
          elsif options[:symbolize]
            define_method("#{name}=".to_sym) do |value|
              instance_variable_set("@#{name}".to_sym, value.to_sym)
            end
          end
        end

        def list(name, options = {})
          attr_accessor name
          (@list_names ||= []) << name
          (@validates_children ||= []) << name if options[:validate]
        end

        def hash(name, options = {})
          attr_accessor name
          (@hash_names ||= []) << name
          (@validates_children ||= []) << name if options[:validate]
        end

        def collect_errors(node, all_errors = [])
          if @validates_children
            @validates_children.each do |name|
              attr_val = node.send(name)
              if @hash_names && @hash_names.include?(name)
                attr_val.each_pair { |k,v| v.collect_errors(all_errors) }
              end

              if @list_names && @list_names.include?(name)
                attr_val.each { |v| v.collect_errors(all_errors) }
              end
            end
          end
          all_errors
        end
      end

      attr_reader :errors

      def initialize
        @errors = []
      end

      def validate
      end

      def valid?
        validate
        @errors.any?
      end

      def collect_errors(all_errors = [])
        validate; all_errors.concat(errors)
        self.class.collect_errors(self, all_errors)
      end
    end
  end
end
