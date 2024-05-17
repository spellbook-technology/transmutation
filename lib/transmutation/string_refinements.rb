# frozen_string_literal: true

module Transmutation
  module StringRefinements # rubocop:disable Style/Documentation
    DELIMITERS = %r{[a-z][A-Z]|\s*-\s*|\s*/\s*|\s*:+\s*|\s*_\s*|\s+}

    refine String do
      def camelcase
        return up unless match? DELIMITERS

        split(%r{\s*-\s*|\s*/\s*|\s*:+\s*}).then { |parts| combine parts, :up, "::" }
                                           .then { |text| text.split(/\s*_\s*|\s+/) }
                                           .then { |parts| combine parts, :up }
      end

      def first(maximum = 0)
        return self if empty?
        return self[0] if maximum.zero?
        return "" if maximum.negative?

        self[..(maximum - 1)]
      end

      def up = empty? ? self : first.upcase + self[1, size]

      private

      def combine(parts, method, delimiter = "")
        parts.reduce "" do |result, part|
          next part.public_send method if result.empty?

          "#{result}#{delimiter}#{part.__send__ method}"
        end
      end
    end
  end
end
