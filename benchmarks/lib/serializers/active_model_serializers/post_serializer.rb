# frozen_string_literal: true

module ActiveModelSerializers
  class PostSerializer < ActiveModel::Serializer
    attributes :id, :title, :body

    belongs_to :user
  end
end
