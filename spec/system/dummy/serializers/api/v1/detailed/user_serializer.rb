# frozen_string_literal: true

module Api
  module V1
    module Detailed
      class UserSerializer < Api::V1::UserSerializer
        attributes :first_name, :last_name

        has_many :posts, namespace: "::Api::V1"
      end
    end
  end
end
