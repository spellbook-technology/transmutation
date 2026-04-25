# frozen_string_literal: true

module Alba
  class UserResource
    include Alba::Resource

    attributes :id, :first_name

    attribute :full_name do |resource|
      "#{resource.first_name} #{resource.last_name}"
    end

    many :posts, resource: PostResource
  end
end
