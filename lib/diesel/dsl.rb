require 'diesel/profile'
require 'diesel/endpoint'
require 'diesel/request_context'

module Diesel
  module DSL
    def self.load_profile(name, filename)
      loader = DSL::Loader.new(name)
      loader.instance_eval File.read(filename), filename
      loader.profile
    end

    class LoaderBase
      attr_reader :object

      class << self
        def attribute(name)
          define_method(name) do |val|
            @object.__send__("#{name}=".to_sym, val)
          end
        end
      end

      attribute :description
    end

    module Parameters
      def header(*args, &block)
        ParameterLoader.load_parameters(@object, :header, *args, &block)
      end

      def body(*args, &block)
        ParameterLoader.load_parameters(@object, :body, *args, &block)
      end

      def parameter(*args, &block)
        ParameterLoader.load_parameters(@object, nil, *args, &block)
      end
    end

    #class PartLoader
    #  attr_reader :part

    #  def initialize(*args)
    #    @part = Part.new(*args)
    #  end

    #  def header name, value
    #    @part.set_header(name, value)
    #  end

    #  def body value
    #    @part.body = value
    #  end
    #end
 
    #class ActionLoader < PartLoader
    #  attr_reader :action

    #  def initialize(endpoint, method, options)
    #    @part = @action = Action.new(endpoint, method, options)
    #  end

    #  def multipart(options = {}, &block)
    #    loader = MultipartLoader.new(options)
    #    loader.instance_eval(&block)
    #    action.multipart = loader.multipart
    #  end
    #end

    #class MultipartLoader
    #  attr_reader :multipart

    #  def initialize(options)
    #    @multipart = Multipart.new(options)
    #  end

    #  def part(*args, &block)
    #    loader = PartLoader.new(*args)
    #    loader.instance_eval(&block) if block
    #    multipart.add_part(loader.part)
    #  end
    #end

    class AuthorizationLoader < LoaderBase
      attribute :name
      attribute :nickname
      attribute :pass_as
      attribute :type

      def initialize
        @object = Diesel::Profile::Authorization.new
      end
    end

    class PropertyLoader < LoaderBase
      attribute :name

      def initialize
        @object = Diesel::Profile::Property.new
      end

      def enum(*values)
        @object.enum = values
      end
    end

    class ComplexTypeLoader < LoaderBase
      attribute :name

      def initialize
        @object = Diesel::Profile::ComplexType.new
      end

      def required(*required_properties)
        @object.required = required_properties
      end

      def property(name, &block)
        l = PropertyLoader.new
        l.name(name)
        l.instance_eval(&block) if block
        @object.properties << l.object
      end
    end

    class OperationLoader < LoaderBase
      include Parameters

      attribute :nickname
      attribute :reference_url
      attribute :method

      def initialize
        @object = Diesel::Profile::Operation.new
      end
    end

    class ResourceLoader < LoaderBase
      def initialize(path)
        @object = Diesel::Profile::Resource.new(path)
      end

      def operation(nickname, &block)
        l = OperationLoader.new
        l.nickname(nickname)
        l.instance_eval(&block)
        @object.operations << l.object
      end
    end

    class ParameterLoader < LoaderBase
      attribute :param_type
      attribute :name
      attribute :value
      attribute :required
      attribute :data_type

      def initialize
        @object = Diesel::Profile::Parameter.new
      end

      def self.load_parameters(target, param_type, *args, &block)
        if args.first.is_a?(::Hash)
          args.shift.each_pair do |name, value|
            l = new
            l.param_type(param_type)
            l.name(name)
            l.value(value)
            target.parameters << l.object
          end
        else
          l = new
          l.param_type(param_type)
          l.name(args.first)
          l.instance_eval(&block) if block
          target.parameters << l.object
        end
      end
    end

    class APILoader < LoaderBase
      include Parameters

      attribute :api_version
      attribute :base_path

      def initialize(api_profile)
        @object = api_profile
      end

      def resource(path, &block)
        l = ResourceLoader.new(path)
        l.instance_eval(&block)
        @object.resources << l.object
      end

      def complex_type(name, &block)
        l = ComplexTypeLoader.new
        l.name(name)
        l.instance_eval(&block)
        @object.models << l.object
      end

      def container_type(name, &block)
        l = ContainerTypeLoader.new
        l.name(name)
        l.instance_eval(&block)
        @object.models << l.object
      end

      def api_key(name, &block)
        l = AuthorizationLoader.new
        l.name(name)
        l.type(:api_key)
        l.instance_eval(&block)
        @object.authorizations << l.object
      end
    end

    class Loader
      attr_reader :name
      attr_reader :profile

      def initialize(name)
        @name = name
      end

      def apis(&block)
        @profile = Profile::API.new(name)
        APILoader.new(@profile).instance_eval(&block)
      end
    end
 end
end
