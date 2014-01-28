require 'diesel/profile/api'
require 'diesel/profile/attribute'
require 'diesel/profile/endpoint'
require 'diesel/profile/action/json_body'
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

      def description(desc)
        @object.description = desc
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

    class JSONPostBodyLoader < LoaderBase
      attr_accessor :values

      def initialize
        @object = Diesel::Profile::Action::JSONBody.new(:post)
      end

      def value(name)
        @object.values << name
      end
    end

    class PostActionLoader < LoaderBase
      def json(&block)
        @object = (JSONPostBodyLoader.new.tap { |l| l.instance_eval(&block) }).object
      end
    end

    class EndpointLoader < LoaderBase
      def initialize(name, path)
        @object = Diesel::Profile::Endpoint.new(name, path)
      end

      def attribute name, options = {}
        @object.attributes << Diesel::Profile::Attribute.new(name, options)
      end

      def post &block
        @object.action = (PostActionLoader.new.tap do |l|
          l.instance_eval(&block)
        end).object
      end
    end

    class APILoader < LoaderBase
      def initialize(api_profile)
        @object = api_profile
      end

      def base_uri(base_uri)
        @object.base_uri = base_uri
      end

      def request_headers(headers)
        @object.request_headers = headers
      end

      def attribute(name, options = {})
        @object.attributes << Diesel::Profile::Attribute.new(name, options)
      end

      def endpoint(name, path, &block)
        l = EndpointLoader.new(name, path)
        l.instance_eval(&block)
        @object.endpoints << l.object
      end

      def auth(auth_type, options = {})
        @object.auth_type = auth_type
        @object.auth_options = options
      end
    end

    class Loader
      attr_reader :name
      attr_reader :profile

      def initialize(name)
        @name = name
      end

      def api(&block)
        @profile = Profile::API.new(name)
        APILoader.new(@profile).instance_eval(&block)
      end
    end

 end
end
