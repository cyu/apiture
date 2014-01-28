module Diesel
  class API
    attr_accessor :auth_strategy
    attr_accessor :logger

    def self.inherited(subclass)
      subclass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def base_uri; @base_uri; end
      def base_uri=(uri)
        @base_uri = uri
      end

      def authenticator; @authenticator; end
      def authenticator=(auth)
        @authenticator = auth
        @authenticator.activate(self)
      end
    end

    def initialize
      if self.class.authenticator
        @auth_strategy = self.class.authenticator.create_strategy(self)
      end
    end
  end
end
