# frozen_string_literal: true

module Api
  module V1
    class CommentSerializer < Transmutation::Serializer
      attributes :id, :body
    end
  end
end
