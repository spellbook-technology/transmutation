# frozen_string_literal: true

module Api
  module V1
    class PostSerializer < Transmutation::Serializer
      attributes :id, :title

      attribute :published, if: :first_user? do
        !object.published_at.nil?
      end

      private

      def first_user?
        object.user_id == 1
      end
    end
  end
end
