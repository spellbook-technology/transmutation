# frozen_string_literal: true

module Api
  module V1
    class ProductsController < Api::ApplicationController
      def show
        product = Product.find(params[:id])
        render json: product
      end
    end
  end
end
