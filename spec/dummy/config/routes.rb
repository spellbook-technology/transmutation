# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show]
      resources :posts, only: %i[index show]
      resources :products, only: [:show]
      resources :health, only: [:index] do
        collection do
          get :download
        end
      end
    end
  end
end
