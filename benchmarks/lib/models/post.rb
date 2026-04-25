# frozen_string_literal: true

class Post < Base
  attr_accessor :id, :title, :body, :user_id

  def self.all
    @all ||= [
      Post.new(id: 1, title: "Post 1", body: "Sample body 1", user_id: 1),
      Post.new(id: 2, title: "Post 2", body: "Sample body 2", user_id: 2),
      Post.new(id: 3, title: "Post 3", body: "Sample body 3", user_id: 1)
    ]
  end

  def user
    User.all.find { |user| user.id == user_id }
  end
end
