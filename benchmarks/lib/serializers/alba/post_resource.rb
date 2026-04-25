# frozen_string_literal: true

module Alba
  class PostResource
    include Alba::Resource

    attributes :id, :title, :body

    one :user, resource: UserResource
  end
end
