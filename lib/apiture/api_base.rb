require 'apiture/api_group'

module Apiture
  class APIError < Exception; end
end

module Apiture
  class APIBase
    attr_accessor :options
    attr_reader :logger

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
