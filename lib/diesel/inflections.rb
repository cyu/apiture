module Diesel
  module Inflections

    def self.acronyms
      @@acronyms ||= {}
    end

    def self.acronym_regex
      @@acronym_regex ||= /(?=a)b/
    end

    def camelize(term)
      string = term.to_s
      string = string.sub(/^(?:#{::Diesel::Inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{::Diesel::Inflections.acronyms[$2] || $2.capitalize}" }
      string.gsub!('/', '::')
      string
    end

    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.gsub('::', '/')
      word.gsub!(/(?:([A-Za-z\d])|^)(#{::Diesel::Inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end
