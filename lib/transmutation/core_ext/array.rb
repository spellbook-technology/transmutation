unless Array.method_defined?(:as_json)
  class Array
    def as_json(options = nil) # :nodoc:
      if options
        map { |v| v.as_json(options.dup) }
      else
        map { |v| v.as_json }
      end
    end
  end
end
