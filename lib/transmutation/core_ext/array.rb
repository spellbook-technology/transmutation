# frozen_string_literal: true

unless Array.method_defined?(:as_json)
  class Array # :nodoc:
    def as_json(options = {})
      if options
        map { |v| v.as_json(options.dup) }
      else
        map(&:as_json)
      end
    end
  end
end
