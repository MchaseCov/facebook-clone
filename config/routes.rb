Rails.application.routes.draw do
  root 'journals#index'

  # COMMENTS [comment likes, nested comments]
  resources :comments, only: %i[edit show destroy] do
    resources :likes, only: %i[create], module: :comments
    resources :comments, except: %i[index], module: :comments
  end

  # CONVERSATIONS & MESSAGES
  resources :conversations, only: %i[index create] do
    resources :messages, only: %i[index new create]
  end

  # GROUPS [Journals, Membership]
  resources :groups do
    member do
      get 'members' # 'members' here refers to a URL & respective controller action, not the route method member.
    end
    match 'users/:id', to: 'groups#toggle_membership', via: %i[put delete], as: 'toggle_membership'
    resources :journals, only: %i[index new create], module: :groups
  end

  # JOURNALS [journal likes, comments]
  resources :journals do
    resources :likes, only: %i[create], module: :journals
    resources :comments, except: %i[index], module: :journals
  end

  # USERS [Devise, Journals, Friendships]
  devise_for :users

  resources :users, only: %i[index show] do
    member do # NOTE: may be worth refactoring these back into their respective controller with turbo tag partials
      get 'groups'
      get 'friendships'
      get 'images'
    end
    resources :friendships, only: %i[create destroy] do
      collection do
        get 'accept_friend_request'
        get 'decline_friend_request'
      end
    end
    resources :journals, only: %i[index new create], module: :users
  end

  # FRIEND REQUEST LIST
  resources :friendships, only: [:index]

  # NOTIFICATIONS LIST
  resources :notifications, only: %i[index destroy] do
    member do
      post 'read_all'
    end
  end
  match 'notifications', to: 'notifications#read', via: [:post]
end
