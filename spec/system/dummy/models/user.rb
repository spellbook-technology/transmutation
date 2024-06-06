# frozen_string_literal: true

class User
  attr_accessor :id, :first_name, :last_name

  def initialize(id:, first_name:, last_name:)
    self.id = id
    self.first_name = first_name
    self.last_name = last_name
  end

  def posts
    Post.all.select { |post| post.user_id == id }
  end

  # =====
  # Finder methods
  # =====

  def self.all
    [
      User.new(id: 1, first_name: "John", last_name: "Doe"),
      User.new(id: 2, first_name: "Jane", last_name: "Doe"),
      User.new(id: 3, first_name: "Adam", last_name: "Smith"),
      User.new(id: 4, first_name: "Eve", last_name: "Smith")
    ]
  end

  def self.find(id)
    all.find { |user| user.id == id }
  end

  # =====
  # JSON serialization
  # =====

  def to_json(options = {})
    as_json(options).to_json
  end

  def as_json(_options = {})
    {
      id: id,
      first_name: first_name,
      last_name: last_name
    }
  end
end
