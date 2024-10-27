module Transmutation
  class ObjectSerializer < Serializer
    def as_json(options = {})
      object.as_json(options)
    end
  end
end
