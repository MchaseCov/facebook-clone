Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  resources :posts, only: %i[index edit update destroy]

  resources :groups do
    resources :posts, only: %i[index new create show]
    member do
      get 'members' # 'members' here refers to a URL & respective controller action, not the route method member.
    end
    match 'users/:id', to: 'groups#toggle_membership', via: %i[put delete], as: 'toggle_membership'
  end

  resources :users, only: %i[index show] do
    resources :posts, only: %i[index new create show]
    member do # NOTE: may be worth refactoring these back into their respective controlleer with turbo tag partials
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

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
