module Apiture
  module Utils
    module Inflections

      def self.acronyms
        @@acronyms ||= {}
      end

      def self.acronym_regex
        @@acronym_regex ||= /(?=a)b/
      end

      def camelize(term, uppercase_first_letter = true)
        string = term.to_s
        if uppercase_first_letter
          string = string.sub(/^[a-z\d]*/) { ::Apiture::Utils::Inflections.acronyms[$&] || $&.capitalize }
        else
          string = string.sub(/^(?:#{::Apiture::Utils::Inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
        end
        string.gsub!(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{::Apiture::Utils::Inflections.acronyms[$2] || $2.capitalize}" }
        string.gsub!('/', '::')
        string
      end

      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.gsub('::', '/')
        word.gsub!(/(?:([A-Za-z\d])|^)(#{::Apiture::Utils::Inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

      def constantize(camel_cased_word)
        unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
          raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
        end

        Object.module_eval("::#{$1}", __FILE__, __LINE__)
      end
    end
  end
end

Apiture::Utils::Inflections.extend(Apiture::Utils::Inflections)
