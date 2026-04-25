# frozen_string_literal: true

json.call(post, :id, :title, :body)
json.user do
  json.id post.user.id
  json.first_name post.user.first_name
  json.full_name "#{post.user.first_name} #{post.user.last_name}"
end
