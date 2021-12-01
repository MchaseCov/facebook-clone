Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users
  resources :posts
  resources :groups do
    match 'users/:id', to: 'groups#users', via: %i[put delete], as: "user_update"
    match 'users', to: 'groups#index_users', via: %i[get], as: "users"
  end

  resources :users, only: %i[index show] do\
    resources :friendships, only: %i[index] do
    end
    resources :friendships, only: %i[create destroy] do
      collection do
        get 'accept_friend_request'
        get 'decline_friend_request'
      end
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
