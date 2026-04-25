# frozen_string_literal: true

module PankoSerializer
  class PostSerializer < Panko::Serializer
    attributes :id, :title, :body

    has_one :user
  end
end
