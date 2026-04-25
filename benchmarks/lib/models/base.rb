class Base
  def initialize(**attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def read_attribute_for_serialization(attribute)
    send(attribute)
  end
end
