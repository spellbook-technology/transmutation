# frozen_string_literal: true

module ActiveModelSerializers
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :first_name

    attribute :full_name do
      "#{object.first_name} #{object.last_name}"
    end

    has_many :posts
  end
end
