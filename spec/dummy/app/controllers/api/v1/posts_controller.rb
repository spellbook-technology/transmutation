# frozen_string_literal: true

module Api
  module V1
    class PostsController < Api::ApplicationController
      def index
        posts = Post.all
        render json: posts
      end

      def show
        post = Post.find(params[:id])
        render json: post, namespace: "Detailed"
      end
    end
  end
end
