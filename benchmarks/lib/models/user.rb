# frozen_string_literal: true

class User < Base
  attr_accessor :id, :first_name, :last_name, :organisation_id

  def self.all
    @all ||= [
      User.new(id: 1, first_name: "John", last_name: "Doe", organisation_id: 1),
    ]
  end

  def organisation
    Organisation.all.find { |org| org.id == organisation_id }
  end

  def posts
    Post.all.find_all { |post| post.user_id == id }
  end

  def post_ids
    posts.map(&:id)
  end
end
