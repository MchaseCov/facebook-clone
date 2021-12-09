Rails.application.routes.draw do
  root 'journals#index'

  devise_for :users

  resources :conversations, only: %i[index create] do
    resources :messages, only: %i[index new create]
  end

  resources :journals, only: %i[show new create index edit update destroy] do
    resources :likes, only: %i[create], module: :journals
    resources :comments, module: :journals
  end

  resources :comments, only: %i[edit show destroy] do
    resources :likes, only: %i[create], module: :comments
    resources :comments, module: :comments
  end

  resources :groups do
    resources :journals, only: %i[index new create show], module: :groups
    member do
      get 'members' # 'members' here refers to a URL & respective controller action, not the route method member.
    end
    match 'users/:id', to: 'groups#toggle_membership', via: %i[put delete], as: 'toggle_membership'
  end

  resources :users, only: %i[index show] do
    resources :journals, only: %i[index new create], module: :users
    member do # NOTE: may be worth refactoring these back into their respective controller with turbo tag partials
      get 'groups'
      get 'friendships'
    end
    resources :friendships, only: %i[create destroy] do
      collection do
        get 'accept_friend_request'
        get 'decline_friend_request'
      end
    end
  end

  resources :notifications, only: [:index]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
