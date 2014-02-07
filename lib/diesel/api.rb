module Diesel
  class API
    attr_accessor :logger

    class << self
      def base_path; @base_path; end
      def base_path=(base_path)
        @base_path = base_path
      end

      def endpoints; @endpoints ||= []; end
      def endpoints=(endpoints)
        @endpoints = endpoints
      end

      def authenticator; @authenticator; end
      def authenticator=(auth)
        @authenticator = auth
        @authenticator.activate(self)
      end

      def models; @models ||= {}; end
      def models=(models)
        @models = models
      end
    end

    protected
      def execute(endpoint, options)
        RequestContext.new(self, endpoint, options).perform
      end
  end
end
