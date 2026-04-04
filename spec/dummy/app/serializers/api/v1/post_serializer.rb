# frozen_string_literal: true

module Api
  module V1
    class PostSerializer < Transmutation::Serializer
      attributes :id, :title
    end
  end
end
