# frozen_string_literal: true

class Post
  attr_accessor :id, :title, :body, :user_id, :published_at

  def initialize(id:, title:, body:, user_id: nil, published_at: nil)
    self.id = id
    self.title = title
    self.body = body
    self.user_id = user_id
    self.published_at = published_at
  end

  def user
    User.find(user_id) if user_id
  end

  # =====
  # Finder methods
  # =====

  def self.all
    [
      Post.new(id: 1, title: "First post", body: "First!", user_id: 1, published_at: Time.now),
      Post.new(id: 2, title: "How does this work?", body: "body", user_id: 2, published_at: Time.now),
      Post.new(id: 3, title: "Second post!?", body: "Nope...", user_id: 1, published_at: nil)
    ]
  end

  def self.find(id)
    all.find { |post| post.id == id }
  end

  # =====
  # JSON serialization
  # =====

  def to_json(options = {})
    as_json(options).to_json
  end

  def as_json(_options = {})
    {
      id:,
      title: first_name,
      body: last_name
    }
  end
end
