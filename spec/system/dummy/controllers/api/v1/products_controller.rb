# frozen_string_literal: true

module Api
  module V1
    class ProductsController < Api::ApplicationController
      def show(id)
        post = Product.find(id)

        render json: post
      end
    end
  end
end
