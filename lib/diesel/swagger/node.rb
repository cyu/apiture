require 'diesel/utils/inflections'

module Diesel
  module Swagger
    class Node
      include Diesel::Utils::Inflections

      class << self
        def inherited(base)
          base.instance_variable_set(:@attribute_names, attribute_names.dup)
          base.instance_variable_set(:@list_names, list_names.dup)
          base.instance_variable_set(:@hash_names, hash_names.dup)
        end

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
              instance_variable_set("@#{name}".to_sym, value.nil? ? nil : value.to_sym)
            end
          end
          (@validates_children ||= []) << name if options[:validate]
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
              if attr_val = node.send(name)
                if @hash_names && @hash_names.include?(name)
                  attr_val.each_pair { |k,v| v.collect_errors(all_errors) }

                elsif @list_names && @list_names.include?(name)
                  attr_val.each { |v| v.collect_errors(all_errors) }

                else
                  unless attr_val.respond_to? :collect_errors
                    raise "Expecting #{name} to be a node"
                  end
                  attr_val.collect_errors(all_errors)
                end
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

      def serializable_hash
        h = {}

        if self.class.attribute_names
          self.class.attribute_names.each do |nm|
            if v = __send__(nm)
              h[camelize(nm, false)] = value_or_serializable_hash(v)
            end
          end
        end

        if self.class.list_names
          self.class.list_names.each do |nm|
            if arr = __send__(nm)
              result = arr.map do |v|
                value_or_serializable_hash(v)
              end
              h[camelize(nm, false)] = result if result.any?
            end
          end
        end

        if self.class.hash_names
          self.class.hash_names.each do |nm|
            if value_hash = __send__(nm)
              result = value_hash.reduce({}) do |m,(k,v)|
                m[k] = value_or_serializable_hash(v); m
              end
              h[camelize(nm, false)] = result if result.any?
            end
          end
        end

        h
      end

      private

        def value_or_serializable_hash(v)
          v.respond_to?(:serializable_hash) ? v.serializable_hash : v
        end
    end
  end
end
