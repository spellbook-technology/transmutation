# frozen_string_literal: true

class Comment
  attr_accessor :id, :body, :user_id

  def initialize(id:, body:, user_id: nil)
    self.id = id
    self.body = body
    self.user_id = user_id
  end

  # =====
  # Finder methods
  # =====

  def self.all
    [
      Comment.new(id: 1, body: "First!", user_id: 1),
      Comment.new(id: 2, body: "Second!", user_id: 2),
      Comment.new(id: 3, body: "Third!", user_id: 1)
    ]
  end
end
