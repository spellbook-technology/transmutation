# frozen_string_literal: true

module Api
  module V1
    module Detailed
      class PostSerializer < Api::V1::PostSerializer
        attributes :body
      end
    end
  end
end
