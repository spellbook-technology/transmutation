# frozen_string_literal: true

module Api
  module V1
    module Detailed
      class UserSerializer < Api::V1::UserSerializer
        attributes :first_name, :last_name
      end
    end
  end
end
