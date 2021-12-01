Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users
  resources :posts
  resources :groups do
    resources :friendships, only: %i[index]
    match 'users/:id', to: 'groups#users', via: %i[put delete], as: 'user_update'
  end

  resources :users, only: %i[index show] do
    match 'groups', to: 'groups', via: %i[get], as: 'groups'
    resources :friendships, only: %i[index]
    resources :friendships, only: %i[create destroy] do
      collection do
        get 'accept_friend_request'
        get 'decline_friend_request'
      end
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
