# frozen_string_literal: true

class Post < ActiveRecord::Base
  belongs_to :user, optional: true
end
