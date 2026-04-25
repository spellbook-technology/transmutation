# frozen_string_literal: true

json.call(user, :id, :first_name)
json.full_name "#{user.first_name} #{user.last_name}"
json.posts user.posts do |post|
  json.call(post, :id, :title, :body)
end
