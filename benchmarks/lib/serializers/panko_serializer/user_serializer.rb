# frozen_string_literal: true

module PankoSerializer
  class UserSerializer < Panko::Serializer
    attributes :id, :first_name, :full_name

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    has_many :posts
  end
end
