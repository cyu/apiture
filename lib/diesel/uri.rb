module Diesel
  class URI

    components = [:scheme, :host, :base_host, :subdomain, :base_path, :resource_path]

    attr_reader *components

    components.each do |comp|
      define_method "#{comp}=".to_sym do |v|
        instance_variable_set("@#{comp}", v)
        build_url
      end
    end

    def to_s
      build_url
    end

    protected

      def build_url
        host = if base_host && subdomain
                 [subdomain, base_host].join('.')
               else
                 self.host
               end
        [
          scheme,
          '://',
          host,
          base_path,
          resource_path
        ].join('')
      end
  end
end
