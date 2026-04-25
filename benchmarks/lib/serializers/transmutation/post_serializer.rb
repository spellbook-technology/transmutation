# frozen_string_literal: true

module Transmutation
  class PostSerializer < Transmutation::Serializer
    attributes :id, :title, :body

    belongs_to :user
  end
end
