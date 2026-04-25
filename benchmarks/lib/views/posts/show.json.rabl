# frozen_string_literal: true

object @post
attributes :id, :title, :body
child(:user) do
  attributes :id, :first_name
  node(:full_name) { |user| "#{user.first_name} #{user.last_name}" }
end
