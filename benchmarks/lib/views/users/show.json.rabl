# frozen_string_literal: true

object @user
attributes :id, :first_name
node(:full_name) { |user| "#{user.first_name} #{user.last_name}" }
child(:posts) do
  attributes :id, :title, :body
end
