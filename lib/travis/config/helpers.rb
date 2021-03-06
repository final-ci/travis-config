require 'hashr'

module Travis
  class Config < Hashr
    module Helpers
      def deep_symbolize_keys(hash)
        hash.inject({}) do |result, (key, value)|
          key = key.to_sym if key.respond_to?(:to_sym)
          result[key] = case value
          when Array
            value.map { |value| value.is_a?(Hash) ? value.deep_symbolize_keys : value }
          when Hash
            value.deep_symbolize_keys
          else
            value
          end
          result
        end
      end

      def deep_merge(hash, other)
        merger = proc { |key, v1, v2| v1.is_a?(Hash) && v2.is_a?(Hash) ? v1.merge(v2, &merger) : v2 || v1 }
        hash.merge(other, &merger)
      end

      def compact(obj)
        case obj
        when Array
          obj.reject { |obj| blank?(obj) }
        when Hash
          obj.keys.each { |key| obj.delete(key) if blank?(obj[key]) }
          obj
        else
          obj
        end
      end

      def blank?(obj)
        obj.respond_to?(:empty?) ? !!obj.empty? : !obj
      end

      def camelize(string)
        string = string.to_s
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
        string.gsub!('/', '::')
        string
      end
    end
  end
end
