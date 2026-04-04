# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < Transmutation::Serializer
      attribute :id
      attribute :full_name do
        "#{object.first_name} #{object.last_name}".strip
      end
    end
  end
end
