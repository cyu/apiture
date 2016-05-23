module Apiture
  class URI

    components = [:scheme, :host, :base_host, :subdomain, :base_path, :resource_path]
    components.each { |comp| attr_reader comp }

    components.each do |comp|
      define_method "#{comp}=".to_sym do |v|
        instance_variable_set("@#{comp}", v)
        build_url
      end
    end

    def merge_components(components)
      components.each_pair do |name, val|
        instance_variable_set("@#{name}", val)
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
