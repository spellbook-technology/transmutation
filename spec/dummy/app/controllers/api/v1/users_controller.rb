# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::ApplicationController
      def index
        users = User.all
        render json: users
      end

      def show
        user = User.find(params[:id])
        render json: user, serializer: "Detailed::UserSerializer"
      end
    end
  end
end
