require 'diesel/api_group'

module Diesel
  class APIError < Exception; end
end

module Diesel
  class APIBase
    attr_accessor :logger, :options

    def initialize(options = {})
      @options = options
    end

    def logger=(logger)
      @logger = logger
      self.class.api_groups.each { |g| g.logger = logger }
    end

    class << self
      def api_groups; @api_groups ||= []; end
      def api_groups=(api_groups)
        @api_groups = api_groups
      end
    end
  end
end
